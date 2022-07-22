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
import StoreKit
import AdSupport
import Photos
import AppsFlyerLib //deeplink
import SideMenu

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var warningWindow: UIWindow?
    var loadingView: UIView?
    var audioPlayer: AVAudioPlayer!
    var downTimer:Timer?
    var currentLanguage = "en"
    var disableStopIndicater = false
    
    var mainNavigationCtrl: BaseNavigationController {
        return appDelegate.window?.rootViewController as! BaseNavigationController
    }
    var mainViewCtrl: MainViewController {
        return appDelegate.mainNavigationCtrl.viewControllers.first as! MainViewController
    }
    
    var mainCtl : MainViewController? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        var countrycode = "us"
        if let identifier = Locale.preferredLanguages.first {
            let local = Locale(identifier: identifier)
            self.currentLanguage = local.languageCode.lowercased()
            if currentLanguage == "en" {
                countrycode = "us"
            }
            else if currentLanguage == "ko" {
                countrycode = "kr"
            }
            else if currentLanguage == "zh" {
                countrycode = "cn"
            }
            else if currentLanguage == "ja" {
                countrycode = "jp"
            }
        }
        
        Bundle.swizzleLocalization()
        ShareData.ins.dfsSet(countrycode, DfsKey.languageCode)
        ShareData.ins.serverLanguageCode = countrycode
        
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.overrideUserInterfaceStyle = .light
//        self.startPreventingRecording()
//        self.startPreventingScreenshot()
        
        if let path = Bundle.main.path(forResource: "bell_30", ofType: ".mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                self.audioPlayer = try AVAudioPlayer.init(contentsOf: url)
                try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                self.audioPlayer.setVolume(0.8, fadeDuration: 0.0)
            } catch {
                
            }
        }
        
        callIntroViewCtrl()
        
        ShareData.ins.dfsRemove(DfsKey.pushData)
        self.initAppsFlyer()
        //앱이 완전 종료 안되고 백그라운드 상태일때 푸쉬 누르면 여기 들어옴
        if let launch = launchOptions, let userInfo = launch[UIApplication.LaunchOptionsKey.remoteNotification] as? [String : Any] {
            self.setPushData(data: userInfo, isBackgroundMode: true)
            self.handleNotificationWhenBackground()
        }
        return true
    }
    private func initAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = AF_DEV_KEY
        AppsFlyerLib.shared().appleAppID = APPLE_APP_ID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().appInviteOneLinkID = "XZU5" //todayisyou.onelink.me/XZU5/806f5794
//        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
//        #if DEBUG
//        AppsFlyerLib.shared().isDebug = true
//        #endif
    }
    func callMemberRegistVc() {
        let vc = MemberRegistViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func callIntroViewCtrl() {
        let vc = IntroViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    func callPermissioVc() {
        let vc = AppPermissionViewCtroller.instantiateFromStoryboard(.login)!
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    func callLoginVC() {
        let vc = LoginViewController.instantiateFromStoryboard(.login)!
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
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
    
//    func apptrakingPermissionCheck() {
//        let adBrix = AdBrixRM.getInstance
//        adBrix.setEventUploadCountInterval(.MIN)
//        adBrix.setLogDelegate(delegate: self)
//        adBrix.initAdBrix(appKey: "OSxxd1KKyUi6q0BNrFTVog", secretKey: "2h7fSMEmRkyZXvfRLj8NXg")
//        adBrix.setLogLevel(.INFO)
//        adBrix.delegateDeeplink = self
//
//        /*
//        PermissionsController.gloableInstance.checkPermissionAppTracking {
//            //            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
//            //                let ifa: UUID = ASIdentifierManager.shared().advertisingIdentifier
//            //                adBrix.setAppleAdvertisingIdentifier(ifa.uuidString)
//            //            }
//            
//            adBrix.startGettingIDFA()
//        } failureBlock: {
//            adBrix.stopGettingIDFA()
//        } deniedBlock: {
//            adBrix.stopGettingIDFA()
//        }
//        */
//    }
//    func removeApnsPushKey() {
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//    }
    func registApnsPushKey() {
//        self.removeApnsPushKey()
        self.registerForRemoteNoti()
    }
    func registerForRemoteNoti() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func startIndicator() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let window = appDelegate.window else {
                return
            }
            if let loadingView = window.viewWithTag(215000) {
                loadingView.removeFromSuperview()
            }
            AppDelegate.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.removeLoadingView), object: nil)
            self.loadingView = UIView(frame: UIScreen.main.bounds)
            self.window!.addSubview(self.loadingView!)
            self.loadingView?.tag = 215000
            self.loadingView?.backgroundColor = RGBA(0, 0, 0, 0.2)
            let ivLoading = UIImageView.init()
            self.loadingView?.addSubview(ivLoading)
            ivLoading.translatesAutoresizingMaskIntoConstraints = false
            
            ivLoading.centerXAnchor.constraint(equalTo: self.loadingView!.centerXAnchor).isActive = true
            ivLoading.centerYAnchor.constraint(equalTo: self.loadingView!.centerYAnchor).isActive = true
            ivLoading.heightAnchor.constraint(equalToConstant: 50).isActive = true
            ivLoading.widthAnchor.constraint(equalToConstant: 50).isActive = true

           //1초후에 indicator remove 액션 추가
            // 혹시라라도 indicator 계속 돌고 있으면 강제로 제거 해준다.
            self.perform(#selector(self.removeLoadingView), with: nil, afterDelay: 5)
            
            do {
                let gif = try UIImage(gifName: "loading.gif")
                ivLoading.setGifImage(gif, manager: .defaultManager, loopCount: -1)
                window.bringSubviewToFront(self.loadingView!)
            }
            catch {
                
            }
        }
    }
    @objc func removeLoadingView() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+30) {
            if let loadingView = appDelegate.window!.viewWithTag(215000) {
                loadingView.removeFromSuperview()
            }
        }
    }
    func stopIndicator() {
        // mjkim 2021.07.28
        if disableStopIndicater {
            return
        } else {
            DispatchQueue.main.async(execute: {
                if self.loadingView != nil {
                    //                self.loadingView!.stopAnimation()
                    self.loadingView?.removeFromSuperview()
                }
            })
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let param = self.parsingDeepLinkUrl(url.absoluteString), param.isEmpty == false {
            ShareData.ins.dfsSet(param, DfsKey.referalParam)
            print("adbrix referal param: \(param)")
        }
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return false
    }
    //deepling open
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL
        else {
            return false
        }
        
        print("DEEPLINK :: UniversialLink was clicked !! incomingURL - \(incomingURL)")
        print("UNIVERSAL LINK OPEN!!!!!!!!!!!!!!!!!")
        //adflayer
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)

        if let param = self.parsingDeepLinkUrl(incomingURL.absoluteString), param.isEmpty == false {
            ShareData.ins.dfsSet(param, DfsKey.referalParam)
        }
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if deviceToken.count == 0 {
            return
        }
        print("==== apns token:\(deviceToken.hexString)")
        //파이어베이스에 푸쉬토큰 등록
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
//        Messaging.messaging().apnsToken = deviceToken
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
        
        AppsFlyerLib.shared().handlePushNotification(userInfo)
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
    
    func handleNotificationWhenBackground() {
        guard let pushData = ShareData.ins.dfsGet(DfsKey.pushData) as? [String:Any] else { return }
        ShareData.ins.dfsRemove(DfsKey.pushData) //푸시 다시 못들어오게 지움
        print("=== didbecomactive push data \(pushData)")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
            appDelegate.mainNavigationCtrl.popToRootViewController(animated: false)
            
            let data = JSON(pushData)
            do {
                guard let model = try CallingModel.decode(data: data.rawData()) else {
                    print ("callingmodel decode error")
                    return
                }
                
                let type = PushType.find(model.msg_cmd)
                
                //rdSend: 랜덤 영상채팅
                let room_key = data["room_key"].stringValue
                guard room_key.isEmpty == false else {
                    return
                }
                
                let arrTmp = room_key.components(separatedBy: "_")
                var callingTime = arrTmp[1]
                let df = CDateFormatter.init()
                df.dateFormat = "yyyyMMddHHmmss"
                
                if callingTime.count > 14 {
                    callingTime = callingTime.subString(from: 0, to: 14)
                }
                guard let  callingDate = df.date(from: callingTime) else {
                    return
                }
                
                let curDate = Date()
                let comps = curDate - callingDate
                //백그라운드 상태에서 30초 안에 전화 받으면 처리 해준다.
                let min = comps.minute ?? 0
                let sec = comps.second ?? 0
                
                if min <= 0 && sec < 30 {
                    let canCall = self.checkPoint(callType: type, connectedType: .answer)
                    if canCall == true {
                        if type == .cam || type == .rdCam {
                            let vc = CamCallViewController.initWithType(.answer, roomKey: model.room_key, toUserId: model.from_user_id)
                            self.mainNavigationCtrl.pushViewController(vc, animated: true)
                        }
                        else if type == .phone {
                            let vc = PhoneCallViewController.initWithType(.answer, roomKey: model.room_key, toUserId: model.from_user_id)
                            self.mainNavigationCtrl.pushViewController(vc, animated: true)
                        }
                        else if type == .rdSend {
                            let vc = CallConnentionViewController.initWithType(.answer, roomKey: model.room_key, toUserId: model.from_user_id)
                            self.mainNavigationCtrl.pushViewController(vc, animated: true)
                        }
                    }
                    else {
                        self.showPointLackPopup(callType: type)
                    }
                }
            } catch {
                print ("callingmodel decode error")
            }
        }
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.startAppsFlyerLib()
        print("=== didbecomactive")
        self.handleNotificationWhenBackground()
        
//        let df = CDateFormatter()
//        df.dateFormat = "yyyyMMddHHmmss"
//        let curDate = Date()
//        if let lastDateStr = ShareData.ins.dfsGet(DfsKey.updateCheckDate) as? String,
//           let last = df.date(from: lastDateStr), ((curDate - last).hour ?? 0) < 1 {
//            return
//        }
//        else {
//            ShareData.ins.dfsSet(df.string(from: curDate), DfsKey.updateCheckDate)
            showUpdateAlert();
//        }
    }
    
    func showUpdateAlert(){
        let bundleId = Bundle.main.bundleIdentifier
        ApiManager.ins.requestAppstoreConnect(bundleId: bundleId) { res in
            let resultCount = res["resultCount"].intValue
            let result = res["results"].arrayValue
            let version = result[0]["version"].stringValue
            if resultCount == 1 && version.isEmpty == false {
                var curversion = Bundle.main.appVersion
                curversion = curversion.getNumberString()!
                let intCurVersion = Int(curversion) ?? 0
                
                let newVersion = version.getNumberString()!
                let intNewVersion = Int(newVersion) ?? 0
                
                if intNewVersion > intCurVersion {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                        let alert = CAlertViewController.init(type:.alert, title: NSLocalizedString("update_popup_title", comment: "업데이트 안내"), message: NSLocalizedString("update_popup_msg", comment: "새로운 버전으로 업데이트 하시겠습니까?"), actions:nil) { vcs, _ , action in
                            vcs.dismiss(animated: true, completion: nil)
                            if action == 1 {
                                let storeVc = SKStoreProductViewController.init()
                                storeVc.delegate = self
                                //appleId 1564683014
                                let param = [SKStoreProductParameterITunesItemIdentifier:1564683014]
                                storeVc.loadProduct(withParameters: param) { success, error in
                                    if success {
                                        self.window?.rootViewController?.present(storeVc, animated: true, completion: nil)
                                    }
                                }
                            }
                            else {
                                self.showUpdateAlert()
                            }
                        }
                        alert.addAction(.cancel, NSLocalizedString("activity_txt479", comment: "취소"))
                        alert.addAction(.ok, NSLocalizedString("update_popup_ok", comment: "업데이트"))
                        alert.btnFullClose.isUserInteractionEnabled = false
                        self.window?.rootViewController?.present(alert, animated: false, completion: nil)
                    }
                }
            }
        } fail: { erro in
            
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    //종료되기 전에 호출 되는 메소드
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    func showCallingView(_ type:PushType, _ model: CallingModel) {
        if let left = SideMenuManager.default.leftMenuNavigationController {
            left.dismiss(animated: false)
        }
        
        let callingView = window?.viewWithTag(TagCallingView)
        if callingView != nil {
            return
        }
        
        CallingView.show(type, model) { [weak self] (model, action) in
            guard let self = self else { return }
            if (action == 100) {    //거절
                self.removeCallingView()
                
                var param:[String:Any] = [:]
                param["from_user_id"] = model.to_user_id
                param["to_user_id"] = model.from_user_id
                param["msg"] = "CAM_NO"
                
                ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
            }
            else if action == 101 { //수락
                self.removeCallingView()
                
                let canCall = self.checkPoint(callType: type, connectedType: .answer)
                
                if canCall == true {
                    
                    if type == .cam  {
                        //영통 받기
                        let vc = CamCallViewController.initWithType(.answer, roomKey: model.room_key, toUserId: model.from_user_id)
                        self.mainNavigationCtrl.pushViewController(vc, animated: true)
                    }
                    else  {
                        //전화 받기
                        let vc = PhoneCallViewController.initWithType(.answer, roomKey: model.room_key, toUserId: model.from_user_id)
                        self.mainNavigationCtrl.pushViewController(vc, animated: true)
                    }
                }
                else {
                    self.showPointLackPopup(callType: type)
                }
            }
            else if action == 200 { //터치시 확장
                if type == .rdSend {
                    self.removeCallingView()
                    let vc = CallConnentionViewController.initWithType(.answer, roomKey: model.room_key, toUserId: model.from_user_id)
                    self.mainNavigationCtrl.pushViewController(vc, animated: true)
                }
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
        if let rootVc = self.window?.rootViewController, let presentedVc = rootVc.presentedViewController {
            if presentedVc .isKind(of: CAlertViewController.self) {
                presentedVc.dismiss(animated: false)
            }
        }
    }
    
    func setPushData(data:[String:Any], isBackgroundMode:Bool = false) {
        let userInfo = JSON(data)
        let message = userInfo["message"].stringValue
        print("push data: \(userInfo)")
        let info = JSON(parseJSON: message)
        let msg_cmd = info["msg_cmd"].stringValue
        
        if let url = URL(string: userInfo["gcm.notification.url"].stringValue) {
            UIApplication.shared.open(url, options: [:])
            return
        }
        
        guard msg_cmd.length > 0  else {
            return
        }
        
        if isBackgroundMode == true {
            //백그라운드 모드이면 아직 뷰가 생성안됐으므로
            //푸쉬데이터 저장하고 있다가 become 에서 처리
            ShareData.ins.dfsSet(info.dictionaryObject, DfsKey.pushData)
            return
        }
        
        let type = PushType.find(msg_cmd)
        
        if type == .admin {
            let title = info["title"].stringValue
            let memo = info["memo"].stringValue
            self.showAdminPopup(title: title,  msg: memo)
        }
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
            
            if let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as? String, notiYn == "N" {
                param["read_yn"] = true
            }
            
            DBManager.ins.insertChatMessage(param) { (success, error) in
                self.mainViewCtrl.updateUnReadMessageCount()
            }
            
            NotificationCenter.default.post(name: Notification.Name(PUSH_DATA), object: type, userInfo: info.dictionaryObject)
        }
        else if type  == .msgDel {
            let seq = info["seq"].stringValue
            DBManager.ins.deleteChatMessage(messageKey: seq, nil)
            appDelegate.mainViewCtrl.updateUnReadMessageCount()
            NotificationCenter.default.post(name: Notification.Name(PUSH_DATA), object: type, userInfo: info.dictionaryObject)
        }
        else if type == .cam {
            
            let from_user_id = info["from_user_id"].stringValue
            
            var param:[String:Any] = [:]
            param["message_key"] = info["message_key"].stringValue
            param["from_user_id"] = from_user_id
            param["room_key"] = info["room_key"].stringValue
            param["to_user_id"] =  info["user_id"].stringValue
            
            param["memo"] = NSLocalizedString("activity_txt102", comment: "[CAM_TALK]저와 영상 채팅 해요 ^^")
            param["reg_date"] = Date()
            param["read_yn"] = false
            param["type"] = 0
            
            let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as! String
            if notiYn == "N" {
                param["read_yn"] = true
            }
            
            DBManager.ins.insertChatMessage(param) { (success, error) in
                self.mainViewCtrl.updateUnReadMessageCount()
            }
            
            if notiYn == "N" {
                return
            }
//            {"msg_cmd":"CAM",
//                "user_id":"a52fd10c131f149663a64ab074d5b44b",
//                "room_key":"CAM_20220518111942_18",
//                "message_key":"429992",
//                "from_user_id":"8cb61f6bef3c749f70a1416abe9b6a3d"}
            
            do {
                guard var model = try CallingModel.decode(data: info.rawData()) else {
                    print("decode error: calingmodel")
                    return
                }
                model.to_user_id = info["user_id"].stringValue
            
                let req = ["user_id":from_user_id]
                ApiManager.ins.requestGetUserImgTalk(param: req) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        model.from_user_age = res["user_age"].stringValue
                        model.from_user_name = res["user_name"].stringValue
                        model.from_user_gender = res["user_sex"].stringValue
                        model.from_user_img = res["user_img"].stringValue
                        model.from_user_score = res["user_score"].floatValue
                        model.from_user_good_cnt = res["good_cnt"].intValue
                        
                        self.showCallingView(type, model)
                    }
                } fail: { (error) in
                    
                }
            } catch {
                print("decode error: calingmodel")
            }
        }
        else if type == .phone {
            let from_user_id = info["from_user_id"].stringValue
            
            var param:[String:Any] = [:]
            param["message_key"] = info["message_key"].stringValue
            param["from_user_id"] = info["from_user_id"].stringValue
            param["room_key"] = info["room_key"].stringValue
            param["user_id"] = info["user_id"].stringValue
            param["memo"] = NSLocalizedString("activity_txt103", comment: "[PHONE_TALK]저와 음성 통화 해요 ^^")
            param["reg_date"] = Date()
            param["read_yn"] = false
            param["type"] = 0
            
            let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as! String
            if notiYn == "N" {
                param["read_yn"] = true
            }
            
            DBManager.ins.insertChatMessage(param) { (success, error) in
                self.mainViewCtrl.updateUnReadMessageCount()
            }
            
            if notiYn == "N" {
                return
            }
            do {
                guard var model = try CallingModel.decode(data: info.rawData()) else {
                    print("decode error: calingmodel")
                    return
                }
                
                model.to_user_id = info["user_id"].stringValue
                
                let req = ["user_id": from_user_id]
                ApiManager.ins.requestGetUserImgTalk(param: req) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        model.from_user_age = res["user_age"].stringValue
                        model.from_user_name = res["user_name"].stringValue
                        model.from_user_gender = res["user_sex"].stringValue
                        model.from_user_img = res["user_img"].stringValue
                        model.from_user_score = res["user_score"].floatValue
                        model.from_user_good_cnt = res["good_cnt"].intValue
                        
                        self.showCallingView(type, model)
                    }
                } fail: { (error) in
                    
                }
            } catch {
                print("decode error: calingmodel")
                return
            }
        }
        else if type  == .camNo {
            let msg = info["msg"].stringValue
            guard let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as? String, notiYn != "N" else {
                return
            }
            
            self.removeCallingView()
            NotificationCenter.default.post(name: Notification.Name(PUSH_DATA), object: type, userInfo: info.dictionaryObject)
            print(info)
            if msg == "CAM_CANCEL" {
//                print("여기 4")
//                window?.makeBottomTost(NSLocalizedString("activity_txt198", comment: "상대가 취소했습니다."))
            }
            else {
                print("여기 5")
                window?.makeBottomTost(NSLocalizedString("activity_txt312", comment: "상대가 거절했습니다."))
            }
        }
        else if type == .rdSend {
            guard let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as? String, notiYn != "N" else {
                return
            }
//            "msg_cmd": RDSEND,
//             "from_user_gender": 남,
//             "to_user_name": 도담이,
//             "to_user_id": a52fd10c131f149663a64ab074d5b44b,
//             "from_user_name": 총각,
//             "room_key": CAM_202205181059223_0,
//             "from_user_age": 20대,
//             "from_user_id": 8cb61f6bef3c749f70a1416abe9b6a3d,
//             "msg":
            
            
            if notiYn == "N" {
                return
            }
            do {
                guard let model = try CallingModel.decode(data: info.rawData()) else {
                    return
                }
                debugPrint("model: \(String(describing: model))")
                self.showCallingView(type, model)
            } catch {
                print("error: callingmodel decodable error")
            }
            
        }
        else if type == .rdCam {
            
            var param:[String:Any] = [:]
            let from_user_id = info["from_user_id"].stringValue
            param["message_key"] = info["message_key"].stringValue
            param["from_user_id"] = from_user_id
            param["room_key"] = info["room_key"].stringValue
            param["to_user_id"] = info["to_user_id"].stringValue
            param["memo"] = NSLocalizedString("activity_txt102", comment: "[CAM_TALK]저와 영상 채팅 해요 ^^")
            param["reg_date"] = Date()
            param["read_yn"] = true
            param["type"] = 0
            
//            //로걸 디비 저장
            DBManager.ins.insertChatMessage(param) { (success, error) in
                self.mainViewCtrl.updateUnReadMessageCount()
            }
            
            guard let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as? String, notiYn != "N" else {
                return
            }
            NotificationCenter.default.post(name:Notification.Name(PUSH_DATA), object: type, userInfo: info.dictionaryObject)
        }
        else if type == .notice {
            guard let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as? String, notiYn != "N" else {
                return
            }
            let vc = NoticeListViewController.instantiateFromStoryboard(.main)!
            self.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if type == .qnaAnswer {
            
        }
        else if type == .qnaManager {
            
        }
        else if type == .commentMemo {
            
        }
        else if type == .commentGift {
            
        }
        else if type == .block {
            
        }
    }
    
    func showScoreAlert(toUserId:String, toUserName:String?) {
        let scoreView = Bundle.main.loadNibNamed("ScoreView", owner: nil, options: nil)?.first as! ScoreView
        let vc = CAlertViewController.init(type: .custom, title:toUserName, message: nil,  actions: [.cancel, .ok]) { vcs, selItem, action in
            vcs.dismiss(animated: true, completion: nil)
            let score = scoreView.ratingView.rating
            if action == 1 && score > 0 {
                var param = [String:Any]()
                param["user_id"] = ShareData.ins.myId
                param["to_user_id"] = toUserId
                param["to_user_score"] = score
                self.requestScore(param)
            }
        }
        vc.iconImg = UIImage(systemName: "hand.thumbsup.fill")
        vc.addCustomView(scoreView)
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        vc.btnFullClose.isUserInteractionEnabled = false
    }
    
    func requestScore(_ param:[String:Any]) {
        ApiManager.ins.requestGiveScore(param: param) { res in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                appDelegate.window?.makeToast(NSLocalizedString("activity_txt356", comment: "등록완료!!"))
            }
            else {
                print("give score error")
            }
        } fail: { error in
            print("give score error")
        }
    }
    
    func checkPoint(callType:PushType, connectedType:ConnectionType) -> Bool {
        //        #if DEBUG
        //        ShareData.ins.myPoint = NSNumber(integerLiteral: 100)
        //        #endif
        
        //여성은 무료, 남성만 포인트 체크한다.
        if ShareData.ins.mySex == .femail  {
            return true
        }

//        #if DEBUG
//        ShareData.ins.myPoint = NSNumber(integerLiteral: 750)
//        ShareData.ins.dfsSet(ShareData.ins.myPoint, DfsKey.userPoint)
//        #endif
        
        guard let curPoint = ShareData.ins.myPoint, curPoint.intValue > 0 else {
            return false
        }
        
        var basePoint = 0
        if (callType == .cam) {
            basePoint = 1200
            if let bPoint = ShareData.ins.dfsGet(DfsKey.camOutStartPoint) as? NSNumber, bPoint.intValue > 0 {
                basePoint = bPoint.intValue
            }
        }
        else if callType == .phone {
            basePoint = 600
            if let bPoint = ShareData.ins.dfsGet(DfsKey.phoneOutStartPoint) as? NSNumber, bPoint.intValue > 0 {
                basePoint = bPoint.intValue
            }
        }
 
        if curPoint.intValue < basePoint  {
            return false
        }
        return true
    }
    
    //포인트 부족 팝업
    func showPointLackPopup(callType:PushType) {
        var nowPoint = 0
        if let point = ShareData.ins.myPoint, point.intValue > 0 {
            nowPoint = point.intValue
        }
        
        var basePoint = 0
        if (callType == .cam) {
            basePoint = 1200
            if let bPoint = ShareData.ins.dfsGet(DfsKey.camOutStartPoint) as? NSNumber, bPoint.intValue > 0 {
                basePoint = bPoint.intValue
            }
        }
        else if callType == .phone {
            basePoint = 600
            if let bPoint = ShareData.ins.dfsGet(DfsKey.phoneOutStartPoint) as? NSNumber, bPoint.intValue > 0 {
                basePoint = bPoint.intValue
            }
        }
        
        let title = NSLocalizedString("activity_txt451", comment: "포인트가 부족 합니다.")
        
        if (nowPoint < 0) {
            nowPoint = 0
        }
        let msg = "\(nowPoint) \(NSLocalizedString("activity_txt449", comment: "포인트가 남아 있습니다.\n최소")) \(basePoint)  \(NSLocalizedString("activity_txt450", comment: "포인트가 필요 합니다."))"
        
        let vc = CAlertViewController.init(type: .alert,title: title, message: msg, actions: nil) { vcs, selItem, action in
            vcs.dismiss(animated: true, completion: nil)
            
            if action == 1 {
                let pointVc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
                appDelegate.mainNavigationCtrl.pushViewController(pointVc, animated: true)
            }
        }
        vc.addAction(.cancel, NSLocalizedString("activity_txt479", comment: "취소"))
        vc.addAction(.ok, NSLocalizedString("activity_txt452", comment: "충전"))
        appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
    }
    
    //전체공지
    func showAdminPopup(title: String , msg : String) {
        
        let vc = AdminNoticeViewController.instantiateFromStoryboard {
            
        }
        vc.adminTitle = title
        vc.message = msg
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha:0.5)
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        
        appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
    }

    
    func startPreventingRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
        
    }
    
    @objc private func didDetectRecording() {
//        DispatchQueue.main.async {
//            self.hideScreen()
            self.presentwarningWindow()
//        }
    }
    func startPreventingScreenshot() {
//        NotificationCenter.default.addObserver(self, selector: #selector(didDetectScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main) { notification in
            let fetchOptions = PHFetchOptions()
            // 생성 날짜 순으로 정렬
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            // 지정한 옵션으로 정렬된 모든 이미지를 가져옴
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            // 정렬된 이미지 중 가장 최근 이미지를 가져옴
            guard let capturedImage = fetchResult.firstObject else { return }
            
            // 삭제 동작 수행
            PHAssetChangeRequest.deleteAssets([capturedImage] as NSFastEnumeration)
            
//            PHPhotoLibrary.shared().performChanges({
//
//                print("여기 도착 1")
//            }) { isSuccess, error in
//                // 성공, 실패 후 동작 처리
//                (isSuccess) ? print("여기 도착 1") : print("여기 도착 2")
//            }
        }
    }
    
    @objc private func didDetectScreenshot() {
//        DispatchQueue.main.async {
//            self.hideScreen()
            self.presentwarningWindow()
//        }
    }
    private func hideScreen() {
//        if UIScreen.main.isCaptured {
//            window?.isHidden = true
//        } else {
//            window?.isHidden = false
//        }
//        print("isCapture : \(UIScreen.main.isCaptured)")
    }
    private func presentwarningWindow() {
        // Remove exsiting
        warningWindow?.removeFromSuperview()
        warningWindow = nil

        guard let frame = window?.bounds else { return }

        // Warning label
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Screen recording is not allowed at our app!"

        // warning window
        var warningWindow = UIWindow(frame: frame)

        let windowScene = UIApplication.shared
            .connectedScenes
            .first {
                $0.activationState == .foregroundActive
            }
        if let windowScene = windowScene as? UIWindowScene {
            warningWindow = UIWindow(windowScene: windowScene)
        }

        warningWindow.frame = frame
        warningWindow.backgroundColor = .black
        warningWindow.windowLevel = UIWindow.Level.statusBar + 1
        warningWindow.clipsToBounds = true
        warningWindow.isHidden = false
        warningWindow.addSubview(label)

        self.warningWindow = warningWindow

        UIView.animate(withDuration: 0.15) {
            label.alpha = 1.0
            label.transform = .identity
        }
        warningWindow.makeKeyAndVisible()
    }
    
    func parsingDeepLinkUrl(_ url: String) -> [String:Any]? {
        var referalParam: [String:Any]? = nil
        do {
            let arr = url.components(separatedBy: "?")
            if let quryparam = arr.last {
                let parameters = quryparam.components(separatedBy: CharacterSet(charactersIn: "=&"))
                var i = 0
                referalParam = [String:Any]()
                while i < parameters.count {
                    let key: String = parameters[i]
                    let value: String = parameters[i+1]
                    referalParam?[key] = value
                    i = i+2
                }
                
                return referalParam
            }
            return referalParam
        }
        catch {
            return referalParam
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //앱이 켜진상태, Forground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        guard let userInfo = notification.request.content.userInfo as? [String:Any] else {
            return
        }
        
        self.setPushData(data: userInfo, isBackgroundMode: false)
        
        
        print("push data willPresent: ==== \(userInfo)")
        print("categoryIdentifier: \(notification.request.content.categoryIdentifier)")
        completionHandler([.badge, .sound])
    }
    
    //앱이 백그라운드 들어갔을때 푸쉬온것을 누르면 여기 탄다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("==== push data didReceive")
        
        if let userInfo = response.notification.request.content.userInfo as? [String : Any] {
            self.setPushData(data: userInfo, isBackgroundMode: true)
            print("==== push data didReceive: \(userInfo)")
        }
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("==== fcm token key not receive")
            return
        }
        print("fcm token: \(token)")
        
        if let userId = ShareData.ins.dfsGet(DfsKey.userId) {
            let param = ["fcm_token": token, "user_id": userId]
            ApiManager.ins.requestUpdateFcmToken(param: param) { (res) in
                if res["isSuccess"].stringValue == "01"{
                    print("fcm upload success")
                }
                else {
                    self.window?.makeToast("fcm token update error")
                }
            } failure: { (error) in
                self.window?.makeToast("fcm token update error")
            }
        }
        else {
            ApiManager.ins.requestReigstPushToken(param: ["fcm_token":token]) { (res) in
                let fcm_cnt = res["fcm_cnt"].intValue
                print("fcm regist success")
                if fcm_cnt > 1 {
                    print("handler fcmkey")
                }
            } failure: { (error) in
                self.window?.makeToast("fcm token update error")
            }
        }
    }
    
}
extension AppDelegate : SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

//adflyer
extension AppDelegate: AppsFlyerLibDelegate, DeepLinkDelegate {
    //local method
    func startAppsFlyerLib() {
        AppsFlyerLib.shared().start { result, error in
            if let error = error {
                print("==== af start error: \(error)")
            }
            else {
                print("==== af start: \(String(describing: result))")
            }
        }
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable : Any]) {
        
        for (key, value) in data {
            print(key, ":", value)
        }
        
        if let status = data["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = data["media_source"],
                   let campaign = data["campaign"] {
                    print("[AFSDK] This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("[AFSDK] This is an organic install.")
            }
            if let is_first_launch = data["is_first_launch"] as? Bool,
               is_first_launch {
                print("[AFSDK] First Launch")
            } else {
                print("[AFSDK] Not First Launch")
            }
        }
    }
    func onConversionDataFail(_ error: Error) {
        print("[AFSDK] \(error)")
    }
    
    //deeplink url parser
    func didResolveDeepLink(_ result: DeepLinkResult) {
        switch result.status {
        case .notFound:
            print("Deep link not found")
        case .found:
            let deepLinkStr:String = result.deepLink!.toString()
            print("DeepLink data is: \(deepLinkStr)")
            
            if( result.deepLink?.isDeferred == true) {
                print("This is a deferred deep link")
            } else {
                print("This is a direct deep link")
            }
    
            if let param = self.parsingDeepLinkUrl(deepLinkStr), param.isEmpty == false {
                ShareData.ins.dfsSet(param, DfsKey.referalParam)
                print("appflyer referal param: \(param)")
            }
        case .failure:
            print("Error %@", result.error!)
        }
    }
}
