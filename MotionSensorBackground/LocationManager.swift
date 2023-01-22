//
//  LocationManager.swift
//  MotionSensorBackground
//
//  Created by Yuuto on 2023/01/21.
//


import CoreLocation
import CoreMotion
import UserNotifications


class LocationAndMotionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // モーションセンサーの変数
    @Published var isStarted = false
    @Published var xStr = "0.0"
    @Published var yStr = "0.0"
    @Published var zStr = "0.0"
    
    // 位置情報の変数
    @Published var authorizationStatus: CLAuthorizationStatus  // 位置情報許可の状態
    @Published var lastSeenLocation: CLLocation?  // 最新の位置情報
    
    // モジュールインスタンス化
    private let motionManager = CMMotionManager()  // モーションセンサー
    private let locationManager = CLLocationManager()  // 位置情報
    
    // 位置情報のデリゲートなどの初期値設定
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self  // 自身のクラスをデリゲートに設定
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  // 最高精度の位置情報
        locationManager.allowsBackgroundLocationUpdates = true  // バックグラウンド実行中も座標取得する場合、trueにする
        locationManager.pausesLocationUpdatesAutomatically = false  // 途中で位置情報のアプデを自動で止めるか
    }
    
    // モーションセンサーと位置情報の記録開始
    func start() {
        if motionManager.isDeviceMotionAvailable {
            locationManager.startUpdatingLocation()  // 位置情報取得開始
            motionManager.deviceMotionUpdateInterval = 0.1  // モーションセンサーの記録を0.1秒ごとに
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.updateMotionData(deviceMotion: motion!)  // モーションセンサーの記録開始
            })
        }
        isStarted = true
    }
    
    // モーションセンサーと位置情報の記録終了
    func stop() {
        isStarted = false
        locationManager.stopUpdatingLocation()  // 位置情報取得終了
        motionManager.stopDeviceMotionUpdates()  // モーションセンサー取得終了
    }
    
    // モーションセンサーを取得する関数（とりあえず加速度）
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        let xDouble = deviceMotion.userAcceleration.x
        let yDouble = deviceMotion.userAcceleration.y
        let zDouble = deviceMotion.userAcceleration.z
        xStr = String(xDouble)
        yStr = String(yDouble)
        zStr = String(zDouble)
        print("xAccel: " + xStr)  // バックグラウンドでも動き続けることを確認する
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization() // バックグラウンド実行中も座標取得する
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
    }
}
