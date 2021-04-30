//
//  AppDelegate.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import CoreData
import Firebase
import CryptoSwift
import FirebaseMessaging
import SwiftyJSON
import AVFoundation


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loadingView: UIView?
    var audioPlayer: AVAudioPlayer!
    var downTimer:Timer?
    
    
    static var ins: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var mainNavigationCtrl: BaseNavigationController {
        return AppDelegate.ins.window?.rootViewController as! BaseNavigationController
    }
    var mainViewCtrl: MainViewController {
        return AppDelegate.ins.mainNavigationCtrl.viewControllers.first as! MainViewController
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        self.registApnsPushKey()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.overrideUserInterfaceStyle = .light
        
        do {
            let path = Bundle.main.path(forResource: "bell_30", ofType: ".mp3")
            let url = URL(fileURLWithPath: path!)
            self.audioPlayer = try AVAudioPlayer.init(contentsOf: url)
            self.audioPlayer.setVolume(0.8, fadeDuration: 0.0)
            
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
        
        callIntroViewCtrl()
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
//            let vc = CallConnentionViewController.instantiateFromStoryboard(.call)!
//            vc.modalPresentationStyle = .fullScreen
////            vc.data = data
//            self.window?.rootViewController!.present(vc, animated: true, completion: nil)
//            vc.btnPhoneCall.isAnimated = true
//        }
        return true
    }
 
    func callTempView() {
        let vc = MemberInfoViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func callIntroViewCtrl() {
        let vc = IntroViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    func callJoinTermVc() {
        let vc = JoinTermsAgreeViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func callMainViewCtrl() {
        let vc = MainViewController.instantiateFromStoryboard(.main)!
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func openUrl(_ url:String, completion: ((_ success:Bool) -> Void)?) {
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let requestUrl = URL.init(string: encodedUrl) else {
            completion?(false)
            return
        }
        UIApplication.shared.open(requestUrl, options: [:]) { (success) in
            completion?(success)
        }
    }
    func removeApnsPushKey() {
        Messaging.messaging().delegate = nil
    }
    func registApnsPushKey() {
        Messaging.messaging().delegate = self
        self.registerForRemoteNoti()
    }
    func registerForRemoteNoti() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted: Bool, error:Error?) in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async(execute: {
            if self.loadingView == nil {
                self.loadingView = UIView(frame: UIScreen.main.bounds)
            }
            self.window!.addSubview(self.loadingView!)
            self.loadingView?.tag = 100000
            self.loadingView?.startAnimation(raduis: 25.0)
            
            //혹시라라도 indicator 계속 돌고 있으면 강제로 제거 해준다. 10초후에
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+60) {
                if let loadingView = AppDelegate.ins.window!.viewWithTag(100000) {
                    loadingView.removeFromSuperview()
                }
            }
        })
    }
    
    func stopIndicator() {
        DispatchQueue.main.async(execute: {
            if self.loadingView != nil {
                self.loadingView!.stopAnimation()
                self.loadingView?.removeFromSuperview()
            }
        })
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if deviceToken.count == 0 {
            return
        }
        print("==== apns token:\(deviceToken.hexString)")
        //파이어베이스에 푸쉬토큰 등록
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
    }
    
    // 앱이 백그라운드에있는 동안 알림 메시지를 받으면
    //이 콜백은 사용자가 애플리케이션을 시작하는 알림을 탭할 때까지 실행되지 않습니다.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        var topicStr = "todayisyou_w"
        if "남" == ShareData.ins.mySex.rawValue {
            topicStr = "todayisyou_m"
        }
        Messaging.messaging().subscribe(toTopic: topicStr)
        print("push data didReceiveRemoteNotification: ==== \(userInfo)")
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("=== apn token regist failed")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodayIsYou")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
           
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
               let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func showCallingView(_ data:JSON) {
        let callingView = window?.viewWithTag(TagCallingView)
        if callingView != nil {
            return
        }
        
        CallingView.show(data) { (data, action) in
            if (action == 100) {    //거절
                self.removeCallingView()
                var param:[String:Any] = [:]
                param["from_user_id"] =  ShareData.ins.myId
                param["to_user_id"] = data["from_user_id"].stringValue
                param["msg"] = "CAM_NO"
                ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
            }
            else if action == 101 { //수락
                self.removeCallingView()
            }
            else if action == 200 { //터치시 확장
                self.removeCallingView()
                
                let vc = CallConnentionViewController.instantiateFromStoryboard(.call)!
                vc.modalPresentationStyle = .fullScreen
                vc.data = data
                self.mainViewCtrl.present(vc, animated: true, completion: nil)
                
            }
        }
        //30초후에 삭제
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+30) {
            self.removeCallingView()
        }
    }
    
    func removeCallingView() {
        if let callingView = self.window?.viewWithTag(TagCallingView) as? CallingView {
            self.audioPlayer.stop()
            callingView.stopShakTimer()
            callingView.removeFromSuperview()
        }
    }
    
    func setPushData(_ userInfo:[String:Any], _ isForground:Bool = false) {
        let userInfo = JSON(userInfo)
        let message = userInfo["message"].stringValue
        
        let info = JSON(parseJSON: message)
        let msg_cmd = info["msg_cmd"].stringValue
        guard msg_cmd.length > 0  else {
            return
        }
        let type = PushType.getPushType(msg_cmd)
        if type == .chat {
            var param:[String:Any] = [:]
            param["message_key"] = info["message_key"].stringValue
            param["from_user_id"] = info["from_user_id"].stringValue
            
            var memo = info["memo"].stringValue
            if memo.hasPrefix("[FILE]") {
                memo = memo.replacingOccurrences(of: "[FILE]", with: "")
                param["file_name"] = memo
            }
            else {
                param["memo"] = info["memo"].stringValue
            }
            
            param["to_user_id"] = ShareData.ins.myId
            param["reg_date"] = Date()
            param["type"] = 0
            param["read_yn"] = false
            
            if let notiYn = ShareData.ins.dfsObjectForKey(DfsKey.notiYn) as? String, notiYn == "N" {
                param["read_yn"] = true
            }
            
            DBManager.ins.insertChatMessage(param) { (success, error) in
                self.mainViewCtrl.updateUnReadMessageCount()
            }
            
            NotificationCenter.default.post(name: Notification.Name(PUSH_DATA), object: type, userInfo: info.dictionary)
        }
        else if type  == .msgDel {
            let seq = info["seq"].stringValue
            DBManager.ins.deleteChatMessage(messageKey: seq, nil)
            AppDelegate.ins.mainViewCtrl.updateUnReadMessageCount()
            NotificationCenter.default.post(name: Notification.Name(PUSH_DATA), object: type, userInfo: info.dictionary)
        }
        else if type == .cam {
            var param:[String:Any] = [:]
            param["message_key"] = info["message_key"].stringValue
            param["from_user_id"] = info["from_user_id"].stringValue
            param["room_key"] = info["room_key"].stringValue
            let user_id = info["user_id"].stringValue
            param["user_id"] = user_id
            
            param["memo"] = "[CAM_TALK]저와 영상 채팅 해요 ^^"
            param["reg_date"] = Date()
            param["read_yn"] = false
            param["type"] = 0
            let notiYn = ShareData.ins.dfsObjectForKey(DfsKey.notiYn) as! String
            if notiYn == "N" {
                param["read_yn"] = true
            }
            DBManager.ins.insertChatMessage(param) { (success, error) in
                self.mainViewCtrl.updateUnReadMessageCount()
            }
            
            if notiYn != "N" {
                let req = ["user_id":user_id]
                ApiManager.ins.requestGetUserImgTalk(param: req) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        var data = res
                        data["message_key"] = info["message_key"]
                        data["room_key"] = info["room_key"]
                        data["from_user_id"] = info["from_user_id"]
                        data["msg_cmd"] = "CAM"
                        
                        self.showCallingView(data)
                    }
                } fail: { (error) in
                    
                }
            }
        }
        else if msg_cmd  == "PHONE" {
            var param:[String:Any] = [:]
            param["message_key"] = info["message_key"].stringValue
            param["from_user_id"] = info["from_user_id"].stringValue
            param["room_key"] = info["room_key"].stringValue
            let user_id = info["user_id"].stringValue
            param["user_id"] = user_id
            param["memo"] = "[PHONE_TALK]저와 음성 통화 해요 ^^"
            param["reg_date"] = Date()
            param["read_yn"] = false
            param["type"] = 0
            
            let notiYn = ShareData.ins.dfsObjectForKey(DfsKey.notiYn) as! String
            if notiYn == "N" {
                param["read_yn"] = true
            }
            
            DBManager.ins.insertChatMessage(param) { (success, error) in
                self.mainViewCtrl.updateUnReadMessageCount()
            }
            
            if notiYn != "N" {
                let req = ["user_id":user_id]
                ApiManager.ins.requestGetUserImgTalk(param: req) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        var data = res
                        data["message_key"] = info["message_key"]
                        data["room_key"] = info["room_key"]
                        data["from_user_id"] = info["from_user_id"]
                        data["msg_cmd"] = "PHONE"
                        
                        self.showCallingView(data)
                    }
                } fail: { (error) in
                    
                }
            }
        }
        else if msg_cmd  == "CAM_NO" {
            let msg = info["msg"].stringValue
            if msg == "CAM_CANCEL" {
                window?.makeToast("상대가 취소했습니다.")
                NotificationCenter.default.post(name: Notification.Name(PUSH_DATA), object: "CAM_CANCEL", userInfo: info.dictionary)
            }
            else {
                window?.makeToast("상대가 거절했습니다.")
                NotificationCenter.default.post(name: Notification.Name(PUSH_DATA), object: info)
            }
            
        }
        else if msg_cmd  == "RDSEND" {
//            message={"msg_cmd":"RDSEND","msg":"","from_user_name":"산딸기먹자","from_user_gender":"남","from_user_age":"50대","to_user_id":"a52fd10c131f149663a64ab074d5b44b","to_user_name":"오늘의주인공은나야","room_key":"CAM_202104271543516_4","from_user_id":"dfb72903a01f6de393cf4130a2b76638"}}
            guard let notiYn = ShareData.ins.dfsObjectForKey(DfsKey.notiYn) as? String, notiYn != "N" else {
                return
            }
            
            var param:[String:Any] = [:]
            param["message_key"] = info["message_key"].stringValue
            param["from_user_id"] = info["from_user_id"].stringValue
            param["room_key"] = info["room_key"].stringValue
            let user_id = info["user_id"].stringValue
            param["user_id"] = user_id
            
            param["memo"] = "[CAM_TALK]저와 영상 채팅 해요 ^^"
            param["reg_date"] = Date()
            param["read_yn"] = true
            param["type"] = 0
            
            DBManager.ins.insertChatMessage(param) { (success, error) in
                self.mainViewCtrl.updateUnReadMessageCount()
            }
            self.showCallingView(info)
        }
        else if msg_cmd  == "RDCAM" {
            
        }
        else if msg_cmd  == "NOTICE" {
            guard let notiYn = ShareData.ins.dfsObjectForKey(DfsKey.notiYn) as? String, notiYn != "N" else {
                return
            }
            if (isForground) {
                let vc = NoticeListViewController.instantiateFromStoryboard(.main)!
                self.mainNavigationCtrl.pushViewController(vc, animated: true);
            }
        }
        else if msg_cmd  == "QNA_Answer" {
            
        }
        else if msg_cmd  == "QNA_Manager" {
            
        }
        else if msg_cmd  == "COMMENT_MEMO" {
            
        }
        else if msg_cmd  == "COMMENT_GIFT" {
            
        }
        else if msg_cmd  == "BLOCK" {
            
        }
    
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
    //앱이 켜진상태, Forground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        guard let userInfo = notification.request.content.userInfo as? [String:Any] else {
            return
        }
        
        self.setPushData(userInfo, true)
        print("push data willPresent: ==== \(userInfo)")
        print("categoryIdentifier: \(notification.request.content.categoryIdentifier)")
        completionHandler(.sound)
    }
    
    //앱이 백그라운드 들어갔을때 푸쉬온것을 누르면 여기 탄다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("push data didReceive: ==== \(userInfo)")
        guard let aps = userInfo["aps"] as? [String:Any], let alert = aps["alert"] as? [String:Any] else {
            return
        }
        
        //푸쉬 데이터를 어느화면으로 보낼지 판단 한고 보내 주는것 처리해야한다.
        //아직 화면 푸쉬 타입에 따른 화면 정리 안됨
//        ShareData.ins.dfsSetValue(userInfo, forKey: DfsKey.pushData)
    }

    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("===== error: fcm token key not receive")
            return
        }
        print("==== fcm token: \(fcmToken)")
        guard let userId = ShareData.ins.dfsObjectForKey(DfsKey.userId) else {
            return
        }
        let param = ["fcm_token":fcmToken, "user_id": userId]
//        ApiManager.ins.requestReigstPushToken(param: ["fcm_token":fcmToken]) { (res) in
//
//            if res["isSuccess"].stringValue == "01" {
//                let fcm_cnt = res["fcm_cnt"].intValue
//                if fcm_cnt > 1 {
//                }
//            }
//            else {
//                self.window?.makeToast("fcm token update error")
//            }
//        } failure: { (error) in
//            self.window?.makeToast("fcm token update error")
//        }

        ApiManager.ins.requestUpdateFcmToken(param: param) { (res) in
            if res["isSuccess"].stringValue == "01"{
            }
            else {
                self.window?.makeToast("fcm token update error")
            }
        } failure: { (error) in
            self.window?.makeToast("fcm token update error")
        }
    }
}

