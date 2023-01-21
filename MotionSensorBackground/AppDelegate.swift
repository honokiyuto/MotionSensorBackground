//
//  AppDelegate.swift
//  MotionSensorBackground
//
//  Created by Yuuto on 2023/01/21.
//


import Foundation
import UIKit
import MapKit


// アプリのライフサイクル用のクラス
class AppDelegate: NSObject, UIApplicationDelegate{
    
    // アプリが起動した時にする処理
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // プッシュ通知の許可
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("許可されました！")
            } else {
                print("拒否されました...")
            }
        }
        return true
    }
}
