//
//  WeatherViewModel.swift
//  zen-meteo-app
//
//  Created by Angelo Di Gianfilippo on 12/01/21.
//

import Foundation
import CoreLocation

public class WeatherViewModel: ObservableObject {
    @Published var cityName: String = "Loading..."
    @Published var temperature: String = "--"
    @Published var weatherDescription: String = "--"
    @Published var weatherImage: String = ""
    
    @Published var hourlyWeather: [HourlyForecast] = []
    
    @Published var dailyWeather: [DailyForecast] = []
    
    public let weatherService: WeatherService
    
    //Map image
    private let defaultImage = "questionmark"
    private let imageMap = [
        "Drizzle" : "cloud.drizzle.fill",
        "Thenderstorm" : "cloud.bolt.rain.fill",
        "Rain" : "cloud.rain.fill",
        "Snow" : "cloud.snow.fill",
        "Clear" : "sun.max.fill",
        "Clouds" : "smoke.fill",
        "Mist" : "cloud.fog.fill",
        "Fog" : "cloud.fog.fill"
    ]
    
    public init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }

    public func refresh() {
        self.weatherService.loadWeatherData { (weather) in
            DispatchQueue.main.async {
                self.fetchCity(lat: weather.lat, lon: weather.lon)
                self.temperature = weather.temperatureCurrent
                self.weatherDescription = weather.descriptionCurrent
                self.weatherImage = self.imageMap[weather.imageNameCurrent] ?? self.defaultImage
                
                self.hourlyWeather = weather.hourlyForecast
                
                self.dailyWeather = weather.dailyForecast
                
                self.mapImage()
            }
        }
    }

    private func mapImage() {
        //Map image hourly forecast
        for h in hourlyWeather {
            for w in h.weather {
                w.imageName = imageMap[w.imageName] ?? defaultImage
            }
        }
        
        //Map image daily forecast
        for d in dailyWeather {
            for w in d.weather {
                w.imageName = imageMap[w.imageName] ?? defaultImage
            }
        }
    }
    
}

extension WeatherViewModel {
    //Get city name by coordinate
    private func fetchCity(lat: Double, lon: Double) {
        CLGeocoder().reverseGeocodeLocation(.init(latitude: lat, longitude: lon)) { (placemarks, error) in
            let city = placemarks?.first.flatMap {
                "\($0.locality ?? "Err"), \($0.administrativeArea ?? "Err")"
            } ?? "Error"
            self.cityName = city
        }
    }
}
