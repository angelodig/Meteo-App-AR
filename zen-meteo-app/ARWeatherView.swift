//
//  ARWeatherView.swift
//  zen-meteo-app
//
//  Created by Angelo Di Gianfilippo on 21/01/21.
//

import SwiftUI
import ARKit
import RealityKit

struct ARWeatherView: View {
    @Environment(\.presentationMode) var presentationMode
    var weatherViewModel: WeatherViewModel
    
    var body: some View {
        ZStack {
            ARViewContainer(weatherVM: weatherViewModel).ignoresSafeArea()
            
            DismissButton { presentationMode.wrappedValue.dismiss() }
        }
    }
}

//struct ARWeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        ARWeatherView()
//    }
//}

//MARK: ARVIEW Helper
extension ARView: ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("DEACTIVATE")
    }
    
}

//MARK: Subviews
struct ARViewContainer: UIViewRepresentable {
    var weatherVM: WeatherViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.addCoaching()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])
        
        let weatherScene = ARWeatherSceneViewModel(weatherViewModel: weatherVM)
        arView.scene.anchors.append(weatherScene.weatherSceneAnchor)
        
        arView.environment.lighting.intensityExponent = 2
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

struct DismissButton: View {
    var action: () -> Void
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {self.action()}) {
                    Image(systemName: "xmark")
                        .padding()
                        .background(Color.gray)
                        .font(Font.system(.title).bold())
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
            }
            .padding()
            Spacer()
        }
    }
}
