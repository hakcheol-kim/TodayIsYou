//
//  AppDelegate.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        callSeviceTermsViewCtrl()
        return true
    }
    
    func callSeviceTermsViewCtrl() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SeviceTermsViewController")
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
}


