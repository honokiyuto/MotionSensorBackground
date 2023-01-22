# 概要
* CoreMotionをバックグラウンドで動作可能にするソースコードです。
* CoreLocationの位置情報常時許可の仕組みと組み合わせて実現しています。
* iOSアプリの審査が通るかわかりませんが、同様の仕組みでやってそうなアプリはいくつかあります。


# 位置情報を常時許可にする事前設定
1. TARGETS -> Signing & Capabilities -> + Capability　-> Background Modes
1. "Location updates" をチェック
1.Info.plist に以下を追加し、適宜値を記入
    * Privacy - Location Always and When In Use Usage Description
    * Privacy - Location When In Use Usage Description
 
 **参考URL**
 * https://qiita.com/dp_r/items/9ea2f919fce73f5da76d
 * https://from2morrow.com/how-to-use-corelocation-with-swiftui/
 
# モーションセンサーで参考になったサイト
**参考URL**
* https://yukblog.net/core-motion-basics/
* https://from2morrow.com/how-to-use-corelocation-with-swiftui/

# CoreMotionとCoreLocationを組み合わせるといいことを書いてたサイト
**参考URL**
* https://stackoverflow.com/questions/4917780/core-motion-in-the-background
