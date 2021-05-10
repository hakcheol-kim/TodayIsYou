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

let TagCallingView = 1000001
let IsShowTutorial = "IsShowTutorial"
let kPushSetting = "PushSetting"
let PUSH_DATA = "PUSH_DATA"
let AUTH_TIMEOUT_MIN: Double = 3
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
    static let userImg = "user_img"
    static let talkUserImg = "talk_user_img"
    static let camUserImg = "cam_user_img"
    static let connectPush = "connect_push"
    static let inappCnt = "inapp_cnt"
    
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
    static let userBbsPoint = "user_bbs_point"

    static let pushData = "pushData"
    static let checkPermission = "checkPermission"
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
    
    func avatar() -> UIImage? {
        if self == .mail {
            return UIImage(named: "icon_man")
        }
        else {
            return UIImage(named: "icon_female")
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
enum PhotoManageType: Int {
    case normal, cam, talk, photo, profile
}

enum Storyboard: String {
    case main = "Main"
    case login = "Login"
    case call = "Call"
}

enum PushType: String {
    case empty = ""
    case camNo = "CAM_NO" //거절
    case camCancel = "CAM_CANCEL" //거절
    case rdSend = "RDSEND"  //램덤 콜
    case rdCam = "RDCAM"    //램덤 콜
    case chat = "CHAT"  //채팅
    case cam = "CAM"    //영상채팅 신청
    case phone = "PHONE"    //음성통화
    case notice = "NOTICE" //공지사항
    case qnaAnswer = "QNA_Answer"   //Q&A답볍
    case qnaManager = "QNA_Manager" //q&a 관리자 답변
    case commentMemo = "COMMENT_MEMO"  //메세지
    case commentGift = "COMMENT_GIFT" //선물 코멘트
    case msgDel = "MSG_DEL" //채팅방 삭제
    case block = "BLOCK"    //관리자 전달사항
    case camMsg = "CAM_MGS" //영상통화시 채팅
    case connect = "CONNECT" //새로운 유저 접속 알림
    
    static func find(_ str:String) -> PushType {
        if str  == "CAM_NO" {
            return .camNo
        }
        else if str  == "RDSEND" {
            return .rdSend
        }
        else if str  == "RDCAM" {
            return .rdCam
        }
        else if str  == "CHAT" {
            return .chat
        }
        else if str  == "MSG_DEL" {
            return .msgDel
        }
        else if str  == "CAM" {
            return .cam
        }
        else if str  == "PHONE" {
            return .phone
        }
        else if str  == "NOTICE" {
            return .notice
        }
        else if str  == "QNA_Answer" {
            return .qnaAnswer
        }
        else if str  == "QNA_Manager" {
            return .qnaManager
        }
        else if str  == "COMMENT_MEMO" {
            return .commentMemo
        }
        else if str  == "COMMENT_GIFT" {
            return .commentGift
        }
        else if str  == "BLOCK" {
            return .block
        }
        else {
            return .empty
        }
    }
}
enum ConnectionType {
    case answer
    case offer
}
