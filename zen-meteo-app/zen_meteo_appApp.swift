//
//  zen_meteo_appApp.swift
//  zen-meteo-app
//
//  Created by Angelo Di Gianfilippo on 11/01/21.
//

import SwiftUI

@main
struct zen_meteo_appApp: App {
    var body: some Scene {
        WindowGroup {
            let weatherService = WeatherService()
            let viewModel = WeatherViewModel(weatherService: weatherService)
            WeatherView(weatherViewModel: viewModel)
        }
    }
}
