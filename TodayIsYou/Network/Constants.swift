//
//  Constants.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import Foundation
import UIKit
let baseUrlNew = "http://todayisyou.co.kr"
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
    static let languageCode = "languageCode"
}

enum SortedType: String {
    case total = "total"
    case femail = "femail"
    case mail = "mail"

    func displayName() -> String {
        if self == .mail {
            return "layout_txt08".localized
        }
        else if self == .femail {
            return "layout_txt07".localized
        }
        else {
            return "root_display_txt19".localized
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
    static func localizedString(_ gedner:String) ->String {
        if gedner == Gender.mail.rawValue {
            return "root_display_txt21".localized
        }
        else {
            return "root_display_txt20".localized
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

enum TalkMemo: String {
    case talk_memo_0 = "가입인사드립니다"
    case talk_memo_1 = "재미있게 영상 채팅 해요"
    case talk_memo_2 = "먼저 영상 신청해 주세요"
    case talk_memo_3 = "친구가 필요해요"
    case talk_memo_4 = "동갑 친구가 좋아요"
    case talk_memo_5 = "연하가 좋아요"
    case talk_memo_6 = "연상이 좋아요"
    case talk_memo_7 = "개인기 봐주세요"
    case talk_memo_8 = "심심해요"
    case talk_memo_9 = "재미있게 채팅 해요"
    case talk_memo_10 = "먼저 메세지 주세요"
    case talk_memo_11 = "차 한잔 할까요"
    case talk_memo_12 = "영화 볼까요?"
    case talk_memo_13 = "대화하다 친해지면 만나요"
    case talk_memo_14 = "고민 들어 주세요"
    case talk_memo_15 = "포토톡 해요"
    case talk_memo_16 = "애인이 필요해요"
    
    static func localizedString(_ memo: String) -> String {
        if  memo == TalkMemo.talk_memo_0.rawValue { return "talk_memo_0".localized }
        else if  memo == TalkMemo.talk_memo_1.rawValue { return "talk_memo_1".localized }
        else if  memo == TalkMemo.talk_memo_2.rawValue { return "talk_memo_2".localized }
        else if  memo == TalkMemo.talk_memo_3.rawValue { return "talk_memo_3".localized }
        else if  memo == TalkMemo.talk_memo_4.rawValue { return "talk_memo_4".localized }
        else if  memo == TalkMemo.talk_memo_5.rawValue { return "talk_memo_5".localized }
        else if  memo == TalkMemo.talk_memo_6.rawValue { return "talk_memo_6".localized }
        else if  memo == TalkMemo.talk_memo_7.rawValue { return "talk_memo_7".localized }
        else if  memo == TalkMemo.talk_memo_8.rawValue { return "talk_memo_8".localized }
        else if  memo == TalkMemo.talk_memo_9.rawValue { return "talk_memo_9".localized }
        else if  memo == TalkMemo.talk_memo_10.rawValue { return "talk_memo_10".localized }
        else if  memo == TalkMemo.talk_memo_11.rawValue { return "talk_memo_11".localized }
        else if  memo == TalkMemo.talk_memo_12.rawValue { return "talk_memo_12".localized }
        else if  memo == TalkMemo.talk_memo_13.rawValue { return "talk_memo_13".localized }
        else if  memo == TalkMemo.talk_memo_14.rawValue { return "talk_memo_14".localized }
        else if  memo == TalkMemo.talk_memo_15.rawValue { return "talk_memo_15".localized }
        else if  memo == TalkMemo.talk_memo_16.rawValue { return "talk_memo_16".localized }
        else { return "" }
    }
}

enum Age:String {
    case age_1 = "10대"
    case age_2 = "20대"
    case age_3 = "30대"
    case age_4 = "40대"
    case age_5 = "50대"
    case age_6 = "60대"
    case age_7 = "70대"
    case age_8 = "80대"
    
    static func localizedString(_ age:String) -> String {
        if age == Age.age_1.rawValue{ return "age_1".localized }
        else if age == Age.age_2.rawValue{ return "age_2".localized }
        else if age == Age.age_3.rawValue{ return "age_3".localized }
        else if age == Age.age_4.rawValue{ return "age_4".localized }
        else if age == Age.age_5.rawValue{ return "age_5".localized }
        else if age == Age.age_6.rawValue{ return "age_6".localized }
        else if age == Age.age_7.rawValue{ return "age_7".localized }
        else if age == Age.age_8.rawValue{ return "age_8".localized }
        else { return ""}
    }
    
    static func severKey(_ age:String) -> String {
        if age == "age_1".localized { return Age.age_1.rawValue }
        else if age == "age_2".localized { return Age.age_2.rawValue }
        else if age == "age_3".localized { return Age.age_3.rawValue }
        else if age == "age_4".localized { return Age.age_4.rawValue }
        else if age == "age_5".localized { return Age.age_5.rawValue }
        else if age == "age_6".localized { return Age.age_6.rawValue }
        else if age == "age_7".localized { return Age.age_7.rawValue }
        else if age == "age_8".localized { return Age.age_8.rawValue }
        else { return "" }
    }
}

enum Area: String {
    case area_0 = "서울"
    case area_1 = "부산"
    case area_2 = "대구"
    case area_3 = "인천"
    case area_4 = "광주"
    case area_5 = "대전"
    case area_6 = "울산"
    case area_7 = "경기"
    case area_8 = "강원"
    case area_9 = "충북"
    case area_10 = "충남"
    case area_11 = "전북"
    case area_12 = "전남"
    case area_13 = "경북"
    case area_14 = "경남"
    case area_15 = "제주"
    case area_16 = "해외"
    
    static func localizedString(_ area:String) -> String {
        if area == Area.area_0.rawValue { return "area_0".localized }
        else if area == Area.area_1.rawValue { return "area_1".localized }
        else if area == Area.area_2.rawValue { return "area_2".localized }
        else if area == Area.area_3.rawValue { return "area_3".localized }
        else if area == Area.area_4.rawValue { return "area_4".localized }
        else if area == Area.area_5.rawValue { return "area_5".localized }
        else if area == Area.area_6.rawValue { return "area_6".localized }
        else if area == Area.area_7.rawValue { return "area_7".localized }
        else if area == Area.area_8.rawValue { return "area_8".localized }
        else if area == Area.area_9.rawValue { return "area_9".localized }
        else if area == Area.area_10.rawValue { return "area_10".localized }
        else if area == Area.area_11.rawValue { return "area_11".localized }
        else if area == Area.area_12.rawValue { return "area_12".localized }
        else if area == Area.area_13.rawValue { return "area_13".localized }
        else if area == Area.area_14.rawValue { return "area_14".localized }
        else if area == Area.area_15.rawValue { return "area_15".localized }
        else if area == Area.area_16.rawValue { return "area_16".localized }
        else { return "" }
    }
    
    static func severKey(_ area: String) -> String {
        if area == "area_0".localized { return Area.area_0.rawValue}
        else if area == "area_1".localized { return  Area.area_1.rawValue }
        else if area == "area_2".localized { return  Area.area_2.rawValue }
        else if area == "area_3".localized { return  Area.area_3.rawValue }
        else if area == "area_4".localized { return  Area.area_4.rawValue }
        else if area == "area_5".localized { return  Area.area_5.rawValue }
        else if area == "area_6".localized { return  Area.area_6.rawValue }
        else if area == "area_7".localized { return  Area.area_7.rawValue }
        else if area == "area_8".localized { return  Area.area_8.rawValue }
        else if area == "area_9".localized { return  Area.area_9.rawValue }
        else if area == "area_10".localized { return  Area.area_10.rawValue }
        else if area == "area_11".localized { return  Area.area_11.rawValue }
        else if area == "area_12".localized { return  Area.area_12.rawValue }
        else if area == "area_13".localized { return  Area.area_13.rawValue }
        else if area == "area_14".localized { return  Area.area_14.rawValue }
        else if area == "area_15".localized { return  Area.area_15.rawValue }
        else if area == "area_16".localized { return  Area.area_16.rawValue }
        else { return "" }
    }
}
enum ConnectionType {
    case answer
    case offer
}
