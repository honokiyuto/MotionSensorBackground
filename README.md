# 概要
* **SwiftUI**を使って、**CoreMotion**をバックグラウンドで起動させたかった。
* **CoreMotion単体**では、**フォアグラウンド限定**で、バックグラウンドでは動かせないと知る。
* 色々記事を見ていると、[ここ]()とかに**CoreLocation**で位置情報を常に許可したら、バックグラウンドでも使えるということも知る。
* [参考になる記事](https://hitonomichi.hatenablog.com/entry/2015/05/29/193719)はあれど、iOS8だったので、新しい情報に巡り会えなかったので、ここに記録する。


# 環境
* iOS: 16.1
* macOS: 13.0
* XCode: 14.1

# ソースコード全文
https://github.com/yutohonoki0708/MotionSensorBackground

* 位置情報の設定(忘れてたので追記)

   1. TARGETS -> Signing & Capabilities -> + Capability　-> Background Modes
"Location updates" をチェック 

   1. Info.plist に以下を追加し、適宜値を記入
      * Privacy - Location Always and When In Use Usage Description
      * Privacy - Location When In Use Usage Description


* 以下は、CoreLocationとCoreMotionを組み合わせた部分。ここまで融合させなくてもいけるのでしょうか。`start()`のメソッドで位置情報とモーションの取得を開始させて、STOPで両方切ってます。`.allowsBackgroundLocationUpdates`の設定とやらでバックグラウンドになっても常に位置情報を取っているので、一緒にモーションも取ってくれているという算段。

    ```swift:LocationManager.swift
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
    
    ```
* 以下は、SwifuUIのフロントエンド部分です。ちなみに`@EnvironmentObject`にこだわりはありません`@StateObject`でも`@ObservedObject`でも動くことを確認しました。

    ```swift:ContentView.swift
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
    ```

* `@EnvironmentObject`にした場合、Appのところは`.environmentObject(~~)`を忘れずに。

    ```swift:MotionSensorBackgroundApp.swift
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
    ```


# 結果画像


* 画面。これはエミュレータのスクショですが、モーションセンサとかやるので、デベロッパモードでiPhoneでやらないと動作確認できませんね。
    <img width="50%" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2918864/051992ec-84f7-d9bd-e82d-e351912737b0.png">

* アプリを起動して、STARTを押す。試しにホームに戻ってバックグラウンドにしてみても、動いているっぽい。放置してみたら、**180分**以上いけたのでSTOPしない限り動くでしょう。
    ![IMG_1674_MOV_AdobeExpress.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2918864/f2071add-9251-609f-259d-51f785011761.gif)


# 参考URL
* 位置情報関係で参考になった記事
    * https://qiita.com/dp_r/items/9ea2f919fce73f5da76d
    * https://from2morrow.com/how-to-use-corelocation-with-swiftui/
    
 
* モーションセンサーで参考になった記事
    * https://yukblog.net/core-motion-basics/
    * https://from2morrow.com/how-to-use-corelocation-with-swiftui/

* CoreMotionとCoreLocationを組み合わせるといいことを書いてた記事
    * https://stackoverflow.com/questions/4917780/core-motion-in-the-background
    * https://hitonomichi.hatenablog.com/entry/2015/05/29/193719
