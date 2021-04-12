//
//  APIResponse.swift
//  zen-meteo-app
//
//  Created by Angelo Di Gianfilippo on 11/01/21.
//

import Foundation

struct APIResponse: Decodable {
    let lat: Double
    let lon: Double
    let current: APICurrent
    let hourly: [APIHourly]
    let daily: [APIDaily]
}

struct APICurrent: Decodable {
    let dateTime: Int
    let temp: Double
    let weather: [APIWeather]
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case temp
        case weather
    }
}

struct APIHourly: Decodable {
    let dateTime: Int
    let temp: Double
    let weather: [APIWeather]
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case temp
        case weather
    }
}

struct APIDaily: Decodable {
    let dateTime: Int
    let temp: APITempDaily
    let weather: [APIWeather]
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case temp
        case weather
    }
}

struct APIWeather: Decodable {
    let description: String
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case iconName = "main"
    }
}

struct APITempDaily: Decodable {
    let min: Double
    let max: Double
}
