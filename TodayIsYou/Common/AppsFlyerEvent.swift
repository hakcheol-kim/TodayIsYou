//
//  AdbrixEvent.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/06/03.
//

import UIKit
import AppsFlyerLib

import SwiftyJSON
import Alamofire
enum AppsFlyerEventType: String {
    //AppsFlyer common
    case signup = "signup"
    //custom
    case joinComplete = "join_complete"
    case login = "login"
    case logout = "logout"
    case withdrawal = "withdrawal"
    case screenName = "screenName"
    case inapp = "inapp"
    
    func displayName() -> String {
        if self == .signup { return "회원가입" }
        else if self == .joinComplete { return "회원가입" }
        else if self == .login { return "로그인" }
        else if self == .logout { return "로그아웃" }
        else if self == .withdrawal { return "회원탈퇴" }
        else if self == .screenName { return "화면명" }
        else if self == .inapp { return "인앱결제" }
        else { return "" }
    }
}

class AppsFlyerEvent: NSObject {
    class func addEventLog(_ type:AppsFlyerEventType, _ param:[String:Any]) {
        if type == .inapp {
            AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: param)
        }
        else {
            AppsFlyerLib.shared().logEvent(name: type.displayName(), values: param) { response, error in
                if let response = response {
                    print("In app event callback Success: ", response)
                }
                if let error = error {
                    print("In app event callback ERROR:", error)
                }
            }
        }
    }
}
