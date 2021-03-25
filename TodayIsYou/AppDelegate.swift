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
        KakaoSDKCommon.initSDK(appKey: KakaoNativeAppKey)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.overrideUserInterfaceStyle = .light
        
        self.callTempView()
        return true
        
        //1. 앱캐쉬에 저장되있닌지 찾는다.
        
        if let userId = ShareData.ins.dfsObjectForKey(DfsKey.userId) as? String, userId.length > 0 {
            callMainViewCtrl()
        }
        else {
            //2. 키체인 영역에 저장된 키가 있는지 찾는다. 있다면, userid 생성해서 저장하고 로그인한다.
            let userIdentifier = KeychainItem.currentUserIdentifier
            if (userIdentifier.isEmpty == false) {
                callIntroViewCtrl()
            }
            else {
                callLoginViewCtrl()
            }
        }
        
        return true
    }
    func callTempView() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "MemberInfoViewController") as! MemberInfoViewController
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    func callIntroViewCtrl() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "IntroViewController") as? IntroViewController
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
        
        return false
    }
}


