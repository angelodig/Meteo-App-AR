//
//  WeatherService.swift
//  zen-meteo-app
//
//  Created by Angelo Di Gianfilippo on 11/01/21.
//

import Foundation
import CoreLocation

public final class WeatherService: NSObject {
   
    private let API_KEY = "b6d5ac5d9ad9e9aa39730f8d7ef5b016" //Copy here your API Key from Openweathermap.org
    private let locationManager = CLLocationManager()
    private var completitionHandler: ((Weather) -> Void)?
    
    private var userLocation: CLLocation?
    
    public override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public func loadWeatherData(_ completitionHandler: @escaping((Weather) -> Void)) {
        self.completitionHandler = completitionHandler
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D) {
        guard let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(coordinates.latitude)&exclude=&lon=\(coordinates.longitude)&exclude=minutely,alerts&units=imperial&appid=\(API_KEY)&lang=\(NSLocale.current)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print(error!)
            } else {
                //let httpResponse = response as? HTTPURLResponse
                //print("🔴 Response: ", httpResponse)
                
                if self.API_KEY == "" { print("⚠️⚠️⚠️ Missing API_KEY. Get your it on Openweathermap.org ⚠️⚠️⚠️")}
                
                do {
                    let decoder = JSONDecoder()
                    guard let data = data else { return }
                    let weatherResponse = try decoder.decode(APIResponse.self, from: data)
                    //print("🔴 Weather Response: ", weatherResponse)
                    self.completitionHandler?(Weather(response: weatherResponse))
                } catch {
                    print("Error respose data.", error.localizedDescription)
                }
            }
        }
        dataTask.resume()
    }
    
    
}

extension WeatherService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard self.userLocation == nil else { return }
        makeDataRequest(forCoordinates: location.coordinate)
        self.userLocation = location
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager retrive location", error.localizedDescription)
    }
    
}
