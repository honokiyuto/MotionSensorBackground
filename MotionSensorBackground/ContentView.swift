//
//  ContentView.swift
//  MotionSensorBackground
//
//  Created by Yuuto on 2023/01/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @EnvironmentObject var locationViewModel: LocationAndMotionManager
    
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    var body: some View {
        VStack{
            // 位置情報の許可ステータスに合わせてSwitch
            switch locationViewModel.authorizationStatus {
            case .notDetermined:
                Button {
                    locationViewModel.requestPermission()
                } label: {
                    Text("位置情報の使用を許可する")
                }
            case .restricted:
                Text("位置情報の使用が制限されています。")
                
            case .denied:
                Text("位置情報を使用できません。")
                
            case .authorizedAlways, .authorizedWhenInUse:
                Text("位置情報許可OK！")
                VStack {
                    Text("＜現在地＞")
                        .fontWeight(.heavy)
                        .padding()
                    Text("経度：" + String(coordinate?.longitude ?? 0))
                    Text("緯度：" + String(coordinate?.latitude ?? 0))
                }
                VStack {
                    Text("＜加速度＞")
                        .fontWeight(.heavy)
                        .padding()
                    Text("X：" + locationViewModel.xStr)
                    Text("Y：" + locationViewModel.yStr)
                    Text("Z：" + locationViewModel.zStr)
                    Button {
                        locationViewModel.isStarted ? locationViewModel.stop() : locationViewModel.start()
                    } label: {
                        locationViewModel.isStarted ? Text("STOP") : Text("START")
                    }
                    .frame(width: 100.0, height: 30.0)
                    .background(.blue)
                    .foregroundColor(.white)
                    .padding()
                }
            default:
                Text("Unexpected status")
            }
            
        }
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationAndMotionManager())
    }
}
