//
//  ContentView.swift
//  MotionSensorBackground
//
//  Created by Yuuto on 2023/01/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject var locationViewModel = LocationManager()
    
    var body: some View {
        switch locationViewModel.authorizationStatus {
        case .notDetermined:
            RequestLocationView()
                .environmentObject(locationViewModel)
        case .restricted:
            ErrorView(errorText: "位置情報の使用が制限されています。")
        case .denied:
            ErrorView(errorText: "位置情報を使用できません。")
        case .authorizedAlways, .authorizedWhenInUse:
            TrackingView()
                .environmentObject(locationViewModel)
        default:
            Text("Unexpected status")
        }
    }
}


struct RequestLocationView: View {
    @EnvironmentObject var locationViewModel: LocationManager
    
    var body: some View {
        Button(action: {
            locationViewModel.requestPermission()
        }) {
            Text("位置情報の使用を許可する")
        }
    }
}

struct TrackingView: View {
    @EnvironmentObject var locationViewModel: LocationManager
    
    var body: some View {
        VStack {
            Text("経度：" + String(coordinate?.longitude ?? 0))
            Text("緯度：" + String(coordinate?.latitude ?? 0))
            Text(locationViewModel.xStr)
            Text(locationViewModel.yStr)
            Text(locationViewModel.zStr)
            Button(action: {
                locationViewModel.isStarted ? locationViewModel.stop() : locationViewModel.start()
            }) {
                locationViewModel.isStarted ? Text("STOP") : Text("START")
            }
            if locationViewModel.isFall {
                Text("Falling!!")
                    .foregroundColor(.red)
                Button {
                    locationViewModel.isFall = false
                } label: {
                    Text("I'm OK")
                }
            }
        }
    }
    
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
}


struct ErrorView: View {
    var errorText: String
    
    var body: some View {
        Text(errorText)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        RequestLocationView().environmentObject(LocationManager())
        TrackingView().environmentObject(LocationManager())
        ErrorView(errorText: "エラーメッセージ")
    }
}
