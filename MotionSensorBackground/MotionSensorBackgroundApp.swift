//
//  MotionSensorBackgroundApp.swift
//  MotionSensorBackground
//
//  Created by Yuuto on 2023/01/21.
//

import SwiftUI

@main
struct MotionSensorBackgroundApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
