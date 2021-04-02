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
        
        return true
    }
 
    func callTempView() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "MemberInfoViewController") as! MemberInfoViewController
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func callIntroViewCtrl() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "IntroViewController") as! IntroViewController
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    func callLoginViewCtrl() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "LoginViewController")
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func callMainViewCtrl() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainViewController")
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
    
    
}
