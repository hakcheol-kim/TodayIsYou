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
let cyberUrl = "https://www.cyber1388.kr:447"

let appType: String = "I1"
let KakaoNativeAppKey = "4ed15923e57b40951d49163ec6250484"

let NAVER_URL_SCHEME = "naverlogin.TodayIsYou"
let NAVER_CONSUMER_KEY = "0tmAza03FIS_QaAub7yc"
let NAVER_CONSUMER_SECRET = "IgI_NBEm42"


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
    static let joinType = "joinType"
    static let identifier = "identifier"

    static let userId = "user_id"
    static let userSex = "user_sex"
    static let userName = "user_name"
    static let userArea = "user_area"
    static let notiYn = "noti_yn"
    static let userScore = "user_score"
    static let userAge = "user_age"
    static let goodCnt = "good_cnt"
    static let userPoint = "user_point"
    static let phoneOutStartPoint =  "phone_out_start_point"
    static let camOutUserPoint =  "cam_out_user_point"
    static let camOutStartPoint =  "cam_out_start_point"
    static let userImage =  "user_image"
    static let photoViewPoint =  "photo_view_point"
    static let randomMsgOutPoint =  "random_msg_out_point"
    static let dayLimitPoint =  "day_limit_point"
    static let photoSeq =  "photo_seq"
    static let camDayPoint =  "cam_day_point"
    static let photoDayPoint =  "photo_day_point"
    static let talkMsgOutPoint =  "talk_msg_out_point"
    static let dayLoginPoint =  "day_login_point"
    static let phoneMsgOutPoint =  "phone_msg_out_point"
    static let blockCnt =  "block_cnt"
    static let talkDayPoint =  "talk_day_point"
    static let phoneOutUserPoint =  "phone_out_user_point"
    static let userR =  "user_r"
    static let smsAuth =  "sms_auth"
    static let phoneInUserPoint =  "phone_in_user_point"
    static let camMsgOutPoint =  "cam_msg_out_point"
    static let camPlayPoint =  "cam_play_point"
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
