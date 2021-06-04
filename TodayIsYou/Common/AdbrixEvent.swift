//
//  AdbrixEvent.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/06/03.
//

import UIKit
import AdBrixRM
import SwiftyJSON
enum AdbrixEventType: String {
    //adbrix common
    case signup = "signup"
    //custom
    case joinComplete = "join_complete"
    case login = "login"
    case logout = "logout"
    case withdrawal = "withdrawal"
    case screenName = "screenName"
    
    func displayName() -> String {
        if self == .signup { return "회원가입" }
        else if self == .joinComplete { return "회원가입" }
        else if self == .login { return "로그인" }
        else if self == .logout { return "로그아웃" }
        else if self == .withdrawal { return "회원탈퇴" }
        else if self == .screenName { return "화면명" }
        else { return "" }
    }
}

class AdbrixEvent: NSObject {
    class func addEventLog(_ type:AdbrixEventType, _ param:[String:Any]) {
        let adBrix = AdBrixRM.getInstance
        
        let model = AdBrixRmAttrModel.init()
        for (key, value) in param {
            if let value = value as? Int {
                model.setAttrDataInt(key, value)
            }
            else if let value = value as? String {
                model.setAttrDataString(key, value)
            }
            else if let value = value as? Double {
                model.setAttrDataDouble(key, value)
            }
            else if let value = value as? Bool {
                model.setAttrDataBool(key, value)
            }
        }
        
        model.setAttrDataString("device", "ios")
        model.setAttrDataString("displayName", type.displayName())
        
        if type == .signup {
            adBrix.commonSignUpWithAttr(channel: .AdBrixRmSignUpAppleIdChannel, commonAttr: model, eventDate: Date())
        }
        else {
            adBrix.eventWithAttr(eventName: type.rawValue, value: model)
        }
        print("adbrix : \(type.displayName()), \(param)")
    }
}
