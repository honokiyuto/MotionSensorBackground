//
//  MotionSensorBackgroundApp.swift
//  MotionSensorBackground
//
//  Created by Yuuto on 2023/01/21.
//

import SwiftUI

@main
struct MotionSensorBackgroundApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocationAndMotionManager())
        }
    }
}
