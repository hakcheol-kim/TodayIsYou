//
//  AppDelegate.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import NVActivityIndicatorView
import KakaoSDKAuth
import KakaoSDKCommon
import Firebase
import CryptoSwift
import NaverThirdPartyLogin
import FBSDKCoreKit
import GoogleSignIn
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loadingView: UIView?
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
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        KakaoSDKCommon.initSDK(appKey: KakaoNativeAppKey)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.overrideUserInterfaceStyle = .light
        
        //네이버
        let naverThirdPartyLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        // 네이버 앱으로 인증하는 방식을 활성화하려면 앱 델리게이트에 다음 코드를 추가합니다.
        naverThirdPartyLoginInstance?.isNaverAppOauthEnable = true
        // SafariViewContoller에서 인증하는 방식을 활성화하려면 앱 델리게이트에 다음 코드를 추가합니다.
        naverThirdPartyLoginInstance?.isInAppOauthEnable = true
        // 인증 화면을 iPhone의 세로 모드에서만 사용하려면 다음 코드를 추가합니다.
        naverThirdPartyLoginInstance?.setOnlyPortraitSupportInIphone(true)
        // 애플리케이션 이름
        naverThirdPartyLoginInstance?.appName = Bundle.main.appName
        // 콜백을 받을 URL Scheme
        naverThirdPartyLoginInstance?.serviceUrlScheme = NAVER_URL_SCHEME
        // 애플리케이션에서 사용하는 클라이언트 아이디
        naverThirdPartyLoginInstance?.consumerKey = NAVER_CONSUMER_KEY
        // 애플리케이션에서 사용하는 클라이언트 시크릿
        naverThirdPartyLoginInstance?.consumerSecret = NAVER_CONSUMER_SECRET
        
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        self.callTempView()
//        return true

        callIntroViewCtrl()
        
        self.registApnsPushKey()
        
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
    func callLoginViewCtrl() {
        let vc = LoginViewController.instantiateFromStoryboard(.login)!
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
        DispatchQueue.main.async {
            if self.loadingView == nil {
                self.loadingView = UIView(frame: UIScreen.main.bounds)
                self.loadingView?.backgroundColor = RGBA(0, 0, 0, 0.2)
                
                let size:CGFloat = 35.0
                let indicatorView = NVActivityIndicatorView(frame: CGRect(x: (self.loadingView!.bounds.width - size)/2, y: (self.loadingView!.bounds.height - size)/2, width: size, height: size), type:.ballSpinFadeLoader, color: RGB(230, 50, 70), padding: 0)
                indicatorView.tag = 2001
                
                self.loadingView!.addSubview(indicatorView)
            }
            
            self.window!.addSubview(self.loadingView!)
            self.loadingView!.tag = 2000
            
            guard let indicatorView = self.loadingView!.viewWithTag(2001) as? NVActivityIndicatorView else {
                return
            }
            indicatorView.startAnimating()
        }
    }
    func stopIndicator() {
        DispatchQueue.main.async {
            guard let loadingView = self.loadingView, let indicatorView = self.loadingView!.viewWithTag(2001) as? NVActivityIndicatorView else {
                return
            }
            indicatorView.stopAnimating()
            loadingView.removeFromSuperview()
        }
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        else if let scheme = url.scheme, scheme.hasPrefix("naverlogin") == true {
            let result = NaverThirdPartyLoginConnection.getSharedInstance()?.receiveAccessToken(url)
            if result == CANCELBYUSER {
                print("result: \(String(describing: result))")
                return false
            }
        }
        else if let scheme = url.scheme, scheme.hasPrefix("fb") == true {
            ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }
        else if let scheme = url.scheme, scheme.hasPrefix("com.googleusercontent.apps") {
            return GIDSignIn.sharedInstance().handle(url)
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if deviceToken.count == 0 {
            return
        }
        print("==== apns token:\(deviceToken.hexString)")
        //파이어베이스에 푸쉬토큰 등록
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // 앱이 백그라운드에있는 동안 알림 메시지를 받으면
    //이 콜백은 사용자가 애플리케이션을 시작하는 알림을 탭할 때까지 실행되지 않습니다.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("=== apn token regist failed")
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    //앱이 켜진상태, Forground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        guard let aps = userInfo["aps"] as? [String:Any], let alert = aps["alert"] as? [String:Any] else {
            return
        }
        guard let title = alert["title"] as? String else {
            return
        }
        
        var message:String?
        if let body = alert["body"] as? String {
            message = body
        }
        else if let body = alert["body"] as? [String:Any] {
            
        }
        
        guard let msg = message else {
            return
        }
        
        //        AlertView.showWithOk(title: title, message: msg) { (index) in
        //        }
    }
    
    //앱이 백그라운드 들어갔을때 푸쉬온것을 누르면 여기 탄다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        guard let aps = userInfo["aps"] as? [String:Any], let alert = aps["alert"] as? [String:Any] else {
            return
        }
        //푸쉬 데이터를 어느화면으로 보낼지 판단 한고 보내 주는것 처리해야한다.
        //아직 화면 푸쉬 타입에 따른 화면 정리 안됨
        ShareData.ins.dfsSetValue(userInfo, forKey: DfsKey.pushData)
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
        ApiManager.ins.requestUpdateFcmToken(param: param) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01"{
//                self.window?.makeToast("fcm token update success")
            }
            else {
                self.window?.makeToast("fcm token update error")
            }
        } failure: { (error) in
            self.window?.makeToast("fcm token update error")
        }
    }
}

