//
//  WeatherView.swift
//  zen-meteo-app
//
//  Created by Angelo Di Gianfilippo on 11/01/21.
//

import SwiftUI

struct WeatherView: View {
    
    @ObservedObject var weatherViewModel: WeatherViewModel
    
    @State private var arViewIsPresented: Bool = false
    @State private var imageIsAnimate: Bool = false
    
    var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20.0){
                    
                //MARK: Current
                    HStack {
                        Text(weatherViewModel.cityName)
                            .font(.system(.largeTitle, design: .serif))
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            self.arViewIsPresented.toggle()
                        }) {
                            if arViewIsPresented {
                                ProgressView("Loading")
                            } else {
                                Text("AR")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            }
                        }
                        .fullScreenCover(isPresented: $arViewIsPresented, content: { ARWeatherView(weatherViewModel: weatherViewModel) })
                    }.padding(.horizontal)
                    .padding(.top)
                    
                    VStack(spacing: 0.0) {
                        
                        HStack {
                            Text(weatherViewModel.temperature + "°")
                                .font(.system(size: 80, weight: .bold, design: .serif))
                            Spacer()
                        }.padding(.horizontal)
                        
                        HStack(alignment: .bottom) {
                            Spacer()
                            Text(weatherViewModel.weatherDescription)
                                .font(.system(size: 30, weight: .bold, design: .serif))
                                .multilineTextAlignment(.trailing)
                            
                            Image(systemName: weatherViewModel.weatherImage)
                                .resizable()
                                .frame(width: 150, height: 150, alignment: .bottom)
                                .scaleEffect(imageIsAnimate ? 1 : 1.1)
                                .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true).delay(1))
                                .colorImage(imageName: weatherViewModel.weatherImage)
                                .onAppear(perform: {
                                    self.imageIsAnimate.toggle()
                                })
                        }.padding(.trailing)
                    }
                    Divider()
                        .padding(.horizontal)
                    
                //MARK: Hourly
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        HStack(alignment: .center, spacing: 30) {
                            ForEach(weatherViewModel.hourlyWeather, id: \.id) { hour in
                                VStack(spacing: 10) {
                                    Text(hour.dateTime)
                                        .foregroundColor(.gray)
                                    Image(systemName: hour.weather.first?.imageName ?? "xmark")
                                        .colorImage(imageName: hour.weather.first?.imageName ?? "xmark")
                                    Text("\(hour.temp)°")
                                }.font(.system(size: 20, weight: .bold, design: .serif))
                            }
                        }
                    }).padding(.horizontal)
                    Divider()
                        .padding(.horizontal)
                    
                //MARK: Daily
                    ForEach(weatherViewModel.dailyWeather, id: \.id) { day in
                        HStack {
                            Image(systemName: day.weather.first?.imageName ?? "xmark")
                                .colorImage(imageName: day.weather.first?.imageName ?? "xmark")
                            Text(day.dateTime)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(day.weather.first?.description ?? "xmark")
                                .multilineTextAlignment(.leading)
                            Spacer()
                            HStack {Text(day.temp.min) + Text("°/") + Text(day.temp.max) + Text("°")}.multilineTextAlignment(.trailing)
                        }.font(.system(size: 20, weight: .bold, design: .serif))
                    }.padding(.horizontal)
                }
            }
            .onAppear(perform: { weatherViewModel.refresh() })
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(weatherViewModel: WeatherViewModel.init(weatherService: WeatherService()))
    }
}

//Custom modifier image color
extension View {
    func colorImage(imageName: String) -> some View {
        self.modifier(ColorImage(imageName: imageName))
    }
}

struct ColorImage: ViewModifier {
    private let colorImage = [
        "cloud.drizzle.fill" : Color.blue,
        "cloud.bolt.rain.fill" : Color.blue,
        "cloud.rain.fill" : Color.blue,
        "cloud.snow.fill" : Color.gray,
        "sun.max.fill" : Color.yellow,
        "smoke.fill" : Color.gray,
        "xmark" : Color.black
    ]
    
    let imageName: String
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(colorImage[imageName])
    }

}
