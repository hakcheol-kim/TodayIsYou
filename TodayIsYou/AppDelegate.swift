//
//  AppDelegate.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import NVActivityIndicatorView

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loadingView: UIView?
    static var instance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var mainNavigationCtrl: BaseNavigationController {
        return AppDelegate.instance.window?.rootViewController as! BaseNavigationController
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.overrideUserInterfaceStyle = .light
        callMainViewCtrl()
        
        return true
    }
    
    func callSeviceTermsViewCtrl() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TermsViewController")
        window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
        window?.makeKeyAndVisible()
    }
    
    func callMemberJoinViewCtrl() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MemberJoinViewController")
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
}


