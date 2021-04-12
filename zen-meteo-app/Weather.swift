//
//  Weather.swift
//  zen-meteo-app
//
//  Created by Angelo Di Gianfilippo on 11/01/21.
//

import Foundation

//MARK: Main Weather
public struct Weather {
    let lat: Double
    let lon: Double
    let temperatureCurrent: String
    let descriptionCurrent: String
    let imageNameCurrent: String

    var hourlyForecast = [HourlyForecast]()
    
    var dailyForecast = [DailyForecast]()
    
    
    init(response: APIResponse) {
        lat = response.lat
        lon = response.lon
        temperatureCurrent = "\(Int(response.current.temp))"
        descriptionCurrent = response.current.weather.first?.description ?? ""
        imageNameCurrent = response.current.weather.first?.iconName ?? ""
        
        hourlyForecast = response.hourly.map{HourlyForecast(responseHourly: $0)}
        
        dailyForecast = response.daily.map{DailyForecast(responseDaily: $0)}
    }
    
}

//MARK: Hourly Forecast
class HourlyForecast {
    var id = UUID()
    var dateTime: String
    var temp: String
    var weather = [WeatherForecast]()
    
    init(responseHourly: APIHourly) {
        dateTime = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(responseHourly.dateTime)))
        temp = "\(Int(responseHourly.temp))"
        weather = responseHourly.weather.map{ WeatherForecast(responseWeather: $0) }
    }

    //Date Formatter
    private var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = NSLocale.current
        f.dateFormat = "HH"
        return f
    }()
    
}
//MARK: Weather Forecast
class WeatherForecast {
    var description: String
    var imageName: String
    
    init(responseWeather: APIWeather) {
        description = responseWeather.description
        imageName =  responseWeather.iconName
    }
}

//MARK: Daily Forecast
class DailyForecast {
    var id = UUID()
    var dateTime: String
    var temp: TemperatureDaily
    var weather = [WeatherForecast]()
    
    init(responseDaily: APIDaily) {
        dateTime = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(responseDaily.dateTime)))
        temp = TemperatureDaily(tempDailyResponse: responseDaily.temp)
        weather = responseDaily.weather.map{ WeatherForecast(responseWeather: $0) }
    }
    
    //Date Formatter daily forecast
    private var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = NSLocale.current
        f.dateFormat = "E"
        return f
    }()
    
}

//MARK: Daily Temp
class TemperatureDaily {
    var id = UUID()
    let min: String
    let max: String
    
    init(tempDailyResponse: APITempDaily) {
        min = "\(Int(tempDailyResponse.min))"
        max = "\(Int(tempDailyResponse.max))"
    }
}
