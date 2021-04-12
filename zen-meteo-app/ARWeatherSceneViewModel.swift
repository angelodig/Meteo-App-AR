//
//  ARWeatherSceneViewModel.swift
//  zen-meteo-app
//
//  Created by Angelo Di Gianfilippo on 30/01/21.
//

import Foundation
import UIKit
import RealityKit
import SwiftUI

class ARWeatherSceneViewModel: Entity, HasAnchoring {
    
    var weatherSceneAnchor = ARWeatherScene.WeatherScene()
    
    private let defaultIcon = "default.usdz"
    private let iconMap = [
        "cloud.drizzle.fill" : "drizzle.usdz",
        "cloud.bolt.rain.fill" : "thunder.usdz",
        "cloud.rain.fill" : "rain.usdz",
        "cloud.snow.fill" : "snow.usdz",
        "sun.max.fill" : "sun.usdz",
        "smoke.fill" : "cloud.usdz",
        "cloud.fog.fill" : "fog.usdz"
    ]
    
    required init(weatherViewModel: WeatherViewModel) {
        super.init()
        
        do {
            self.weatherSceneAnchor = try ARWeatherScene.loadWeatherScene()
        } catch {
            print("Error loadWeatherScene:", error)
        }
        
        updateScene(weatherViewModel)
        
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func updateScene(_ weatherViewModel: WeatherViewModel) {
        print("🔴 Scene components: ", weatherSceneAnchor.components)
        
        //Current weather
        self.weatherSceneAnchor.cityName?.children[0].children[0].components.set(generateModelComponentForText(text: weatherViewModel.cityName))
        self.weatherSceneAnchor.description?.children[0].children[0].components.set(generateModelComponentForText(text: weatherViewModel.weatherDescription))
        self.weatherSceneAnchor.temp?.children[0].children[0].components.set(generateModelComponentForText(text: weatherViewModel.temperature + "°"))
        self.weatherSceneAnchor.weatherIcon?.children[0].children[0].children[0].isEnabled = false ///Used as placeholder
        do {
            let iconWeatherEntity = try Entity.load(named: iconMap[weatherViewModel.weatherImage] ?? defaultIcon)
            guard let zPos = self.weatherSceneAnchor.weatherIcon?.position.z else { return }
            iconWeatherEntity.position.z = zPos
            self.weatherSceneAnchor.weatherIcon?.addChild(iconWeatherEntity)
        } catch {
            print("Error load icon entity")
        }
        
        //Next days forecasts
        guard let nextDaysBackground = self.weatherSceneAnchor.nextdaysBackground else { return }
        
        let hightNextDayBackground = nextDaysBackground.visualBounds(relativeTo: nextDaysBackground).max.y - nextDaysBackground.visualBounds(relativeTo: nextDaysBackground).min.y
        var yPosDelta: Float = hightNextDayBackground / 9
        
        ///Add rows
        for day in weatherViewModel.dailyWeather {
            guard let dayWeather = day.weather.first else { return }
            
            var iconEntity = Entity()
            
            do {
                iconEntity = try Entity.load(named: self.iconMap[dayWeather.imageName] ?? self.defaultIcon)
            } catch {
                print("Error load daily icon entity")
            }
            
            let iconWeatherDaily = iconEntity
            iconWeatherDaily.transform.scale = SIMD3(x: 0.05, y: 0.05, z: 0.05)
            iconWeatherDaily.position.z = nextDaysBackground.visualBounds(relativeTo: nextDaysBackground).max.z
            iconWeatherDaily.position.y = nextDaysBackground.visualBounds(relativeTo: nextDaysBackground).max.y - yPosDelta
            iconWeatherDaily.position.x = nextDaysBackground.visualBounds(relativeTo: nextDaysBackground).min.x + 0.01
            nextDaysBackground.addChild(iconWeatherDaily)
            
            let dayText = Entity()
            dayText.components.set(generateModelComponentForText(text: day.dateTime, size: 0.003, extrusion: 0.0001))
            dayText.position.z = iconWeatherDaily.position.z
            dayText.position.y = iconWeatherDaily.position.y
            dayText.position.x = iconWeatherDaily.position.x + 0.01
            nextDaysBackground.addChild(dayText)
            
            let descriptionWeatherDaily = Entity()
            descriptionWeatherDaily.components.set(generateModelComponentForText(text: dayWeather.description, size: 0.003, extrusion: 0.0001))
            descriptionWeatherDaily.position.z = iconWeatherDaily.position.z
            descriptionWeatherDaily.position.y = iconWeatherDaily.position.y
            descriptionWeatherDaily.position.x = dayText.position.x + 0.015
            nextDaysBackground.addChild(descriptionWeatherDaily)
            
            let tempDaily = Entity()
            tempDaily.components.set(generateModelComponentForText(text: (day.temp.min + "°/" + day.temp.max + "°"), size: 0.003, extrusion: 0.0001))
            tempDaily.position.z = iconWeatherDaily.position.z
            tempDaily.position.y = iconWeatherDaily.position.y
            tempDaily.position.x = descriptionWeatherDaily.position.x + 0.045
            nextDaysBackground.addChild(tempDaily)
            
            yPosDelta += hightNextDayBackground / 9
        }
        
    }
    
    private func generateModelComponentForText(text: String, size: CGFloat = 0.08, extrusion: Float = 0.001) -> ModelComponent {
        let mesh: MeshResource = .generateText(text, extrusionDepth: extrusion, font: .systemFont(ofSize: size), containerFrame: CGRect(), alignment: .left, lineBreakMode: .byCharWrapping)
        
        let material: [Material] = [SimpleMaterial(color: .black, isMetallic: true)]
        
        return ModelComponent(mesh: mesh, materials: material)
    }
    
}
