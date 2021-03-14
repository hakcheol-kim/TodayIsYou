//
//  Constants.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import Foundation
import UIKit

let baseUrl = "http://211.233.15.31:8080"
let soketUrl = "http://211.233.15.31:8081"
let rootPath = "api"

public func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
public func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 1.0)
}
struct AppColor {
    static let defaultRed = RGB(230, 50, 70)
    static let borderGray = RGB(221, 221, 221)
}

let IsShowTutorial = "IsShowTutorial"
let kPushSetting = "PushSetting"
let kPushUserData = "PushUserData"


enum SortedType: String {
    case total = "total"
    case femail = "femail"
    case mail = "mail"

    func displayName() -> String {
        if self == .mail {
            return "남성"
        }
        else if self == .femail {
            return "여성"
        }
        else {
            return "전체"
        }
    }
    func key() -> String {
        if self == .mail {
            return "남"
        }
        else if self == .femail {
            return "여"
        }
        else {
            return ""
        }
    }
}
enum Gender: String {
    case mail = "남"
    case femail = "여"
    
    func transGender() -> Gender {
        if self == .mail {
            return .femail
        }
        else {
            return .mail
        }
    }
    
    func avatar() -> String {
        if self == .mail {
            return "icon_man"
        }
        else {
            return "icon_female"
        }
    }
    static func defaultImg(_ gender:String?) -> UIImage? {
        guard let gender = gender as? String else {
            return nil
        }
        
        if gender == Gender.mail.rawValue {
            return UIImage(named: "icon_man")
        }
        else {
            return UIImage(named: "icon_female")
        }
    }
}
enum ListType: String {
    case table = "text"
    case collection = "image"
}
