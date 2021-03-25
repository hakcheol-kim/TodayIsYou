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

let appType: String = "A1"
let KakaoNativeAppKey = "4ed15923e57b40951d49163ec6250484"

let today = "otadiyysuo"
let soup = "#8!"
let ivBlockSize = "drowssap20210215"

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

struct DfsKey {
    static let myPoint = "MyPoint"
    static let mySex = "MySex"
    static let userId = "UserId"
    static let joinType = "joinType"
    static let identifier = "identifier"
}
struct NotiName {
    static let pushData = "pushData"
    
}

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
        guard let gender = gender else {
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

let ageRange = ["10대", "20대", "30대", "40대", "50대", "60대", "70대", "80대"]
let areaRange = ["서울", "부산", "대구", "인천", "광주", "대전", "울산", "경기", "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주", "해외"]
