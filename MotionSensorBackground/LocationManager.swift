//
//  LocationManager.swift
//  MotionSensorBackground
//
//  Created by Yuuto on 2023/01/21.
//

/*
 ＜位置情報を常時許可にする事前設定＞
 （１）TARGETS -> Signing & Capabilities -> +Capability　-> Background Modes選択
 （２）Location updatesにチェック
 （３）Info.plistにPrivacy - Location Always and When In Use Usage Descriptionを設定して値を設定
 （参考：https://qiita.com/dp_r/items/9ea2f919fce73f5da76d）
 
 
 （参考：https://from2morrow.com/how-to-use-corelocation-with-swiftui/）
 */

import CoreLocation
import CoreMotion
import UserNotifications

//ネットからそのまま持ってきたので、著作権注意
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // モーションセンサーの変数
    @Published var isStarted = false  //
    @Published var isFall = false
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
    
    func stop() {
        isStarted = false
        locationManager.stopUpdatingLocation()  // 位置情報取得終了
        motionManager.stopDeviceMotionUpdates()  // モーションセンサー取得終了
    }
    
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        let xDouble = deviceMotion.userAcceleration.x
        let yDouble = deviceMotion.userAcceleration.y
        let zDouble = deviceMotion.userAcceleration.z
        xStr = String(xDouble)
        yStr = String(yDouble)
        zStr = String(zDouble)
        updateFallingStatus(x: xDouble, y: yDouble, z: zDouble)
        print("xStr: " + xStr)
    }
    
    private func updateFallingStatus(x: Double, y:Double, z: Double) {
        let absX = fabs(x)
        let absY = fabs(y)
        let absZ = fabs(z)
        if absX + absY + absZ > 6.25 {
            isFall = true
            print("Fall!!")
            sendNotificationRequest()
        }
    }

    func requestPermission() {
        locationManager.requestAlwaysAuthorization() // バックグラウンド実行中も座標取得する場合はこちら
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
    }
}


// 通知を送る処理
func sendNotificationRequest(){
    
    print("@@@@@@@@@@@@@@@@@@@@@@@通知の関数は通ってるよ@@@@@@@@@@@@@@@@@@@@@")
    
    let content = UNMutableNotificationContent()
    content.sound = UNNotificationSound.default
    content.title = "転倒を検知しました"
    content.subtitle = "通報を行います"
    content.body = "通報を止めたい場合はアプリ内で「I'm OK」ボタンを押してください"
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString , content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
}
