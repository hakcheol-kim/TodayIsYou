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
let baseUrl2 = "https://api3.todayisyou.co.kr"
    
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
    static let updateCheckDate = "updateCheckDate"
    static let eventBanerSeeDate = "eventBanerSeeDate"
    static let referalParam = "referalParam"
    
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
    static func getSortType(_ gender: Gender) -> SortedType {
        if gender == .femail {
            return .femail
        }
        else if gender == .mail {
            return .mail
        }
        else {
            return .total
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
    case other = "Other"
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
        else { return memo }
    }
    static func severKey(_ memo:String) -> String {
        if  memo == "talk_memo_0".localized { return  TalkMemo.talk_memo_0.rawValue}
        else if  memo == "talk_memo_1".localized { return  TalkMemo.talk_memo_1.rawValue }
        else if  memo == "talk_memo_2".localized { return  TalkMemo.talk_memo_2.rawValue }
        else if  memo == "talk_memo_3".localized { return  TalkMemo.talk_memo_3.rawValue }
        else if  memo == "talk_memo_4".localized { return  TalkMemo.talk_memo_4.rawValue }
        else if  memo == "talk_memo_5".localized { return  TalkMemo.talk_memo_5.rawValue }
        else if  memo == "talk_memo_6".localized { return  TalkMemo.talk_memo_6.rawValue }
        else if  memo == "talk_memo_7".localized { return  TalkMemo.talk_memo_7.rawValue }
        else if  memo == "talk_memo_8".localized { return  TalkMemo.talk_memo_8.rawValue }
        else if  memo == "talk_memo_9".localized { return  TalkMemo.talk_memo_9.rawValue }
        else if  memo == "talk_memo_10".localized { return  TalkMemo.talk_memo_10.rawValue }
        else if  memo == "talk_memo_11".localized { return  TalkMemo.talk_memo_11.rawValue }
        else if  memo == "talk_memo_12".localized { return  TalkMemo.talk_memo_12.rawValue }
        else if  memo == "talk_memo_13".localized { return  TalkMemo.talk_memo_13.rawValue }
        else if  memo == "talk_memo_14".localized { return  TalkMemo.talk_memo_14.rawValue }
        else if  memo == "talk_memo_15".localized { return  TalkMemo.talk_memo_15.rawValue }
        else if  memo == "talk_memo_16".localized { return  TalkMemo.talk_memo_16.rawValue }
        else { return memo }
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
        else { return age}
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
        else { return age }
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
        else { return area }
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
        else { return area }
    }
}
enum ChatMsg: String {
//    activity_txt102    [CAM_TALK]저와 영상 채팅 해요 ^^    [CAM_TALK]Video Chat with me ^^
//    activity_txt103    [PHONE_TALK]저와 음성 통화 해요 ^^    [PHONE_TALK]Voice Call with me ^^
//    activity_txt25    안녕하세요 운영자 입니다    Hello this is the owner
    case cam_talk = "[CAM_TALK]저와 영상 채팅 해요 ^^"
    case phone_talk = "[PHONE_TALK]저와 음성 통화 해요 ^^"
    case owner_talk_hello = "안녕하세요 운영자 입니다"
    
    static func localizedString(_ memo:String) -> String {
        if memo == ChatMsg.cam_talk.rawValue { return "activity_txt102".localized }
        else if memo == ChatMsg.phone_talk.rawValue { return "activity_txt103".localized }
        else if memo == ChatMsg.owner_talk_hello.rawValue { return "activity_txt25".localized }
        else { return memo }
    }
    static func severKey(_ memo: String) -> String {
        if memo == "activity_txt102".localized { return ChatMsg.cam_talk.rawValue}
        else if memo == "activity_txt103".localized { return  ChatMsg.phone_talk.rawValue }
        else { return memo }
    }
}
enum Bank: String {
    case bank_0 = "경남은행[39]"
    case bank_1 = "국민은행[04]"
    case bank_2 = "광주은행[34]"
    case bank_3 = "기업은행[03]"
    case bank_4 = "농협중앙회[11]"
    case bank_5 = "단위농협(축협)[12]"
    case bank_6 = "대구은행[31]"
    case bank_7 = "대화은행[65]"
    case bank_8 = "부산은행[32]"
    case bank_9 = "산업은행[02]"
    case bank_10 = "상호저축은행[50]"
    case bank_11 = "새마을금고[45]"
    case bank_12 = "수출입은행[08]"
    case bank_13 = "수협[07]"
    case bank_14 = "통합신한은행[88]"
    case bank_15 = "신협[48]"
    case bank_16 = "씨티은행[27]"
    case bank_17 = "우리은행[20]"
    case bank_18 = "우체국[71]"
    case bank_19 = "외환은행[05]"
    case bank_20 = "전북은행[37]"
    case bank_21 = "제주은행[35]"
    case bank_22 = "카카오뱅크[90]"
    case bank_23 = "케이뱅크[89]"
    case bank_24 = "한국은행[01]"
    case bank_25 = "하나은행[81]"
    case bank_26 = "SC제일은행[23]"
    case bank_27 = "도이치은행[55]"
    case bank_28 = "모건스탠리[52]"
    case bank_29 = "미쓰비시도쿄UFJ은행[59]"
    case bank_30 = "미즈호은행[58]"
    case bank_31 = "비엔피파리바은행[61]"
    case bank_32 = "알비에스피엘씨은행[56]"
    case bank_33 = "제이피모간체이스은행[57]"
    case bank_34 = "중국공상은행[62]"
    case bank_35 = "중국은행[63]"
    case bank_36 = "BOA은행[60]"
    case bank_37 = "HSBC은행[54]"
    
    static func localizedString(_ bank:String) -> String {
        if bank == Bank.bank_0.rawValue { return "bank_0".localized }
        else if bank == Bank.bank_1.rawValue { return "bank_1".localized }
        else if bank == Bank.bank_2.rawValue { return "bank_2".localized }
        else if bank == Bank.bank_3.rawValue { return "bank_3".localized }
        else if bank == Bank.bank_4.rawValue { return "bank_4".localized }
        else if bank == Bank.bank_5.rawValue { return "bank_5".localized }
        else if bank == Bank.bank_6.rawValue { return "bank_6".localized }
        else if bank == Bank.bank_7.rawValue { return "bank_7".localized }
        else if bank == Bank.bank_8.rawValue { return "bank_8".localized }
        else if bank == Bank.bank_9.rawValue { return "bank_9".localized }
        else if bank == Bank.bank_10.rawValue { return "bank_10".localized }
        else if bank == Bank.bank_11.rawValue { return "bank_11".localized }
        else if bank == Bank.bank_12.rawValue { return "bank_12".localized }
        else if bank == Bank.bank_13.rawValue { return "bank_13".localized }
        else if bank == Bank.bank_14.rawValue { return "bank_14".localized }
        else if bank == Bank.bank_15.rawValue { return "bank_15".localized }
        else if bank == Bank.bank_16.rawValue { return "bank_16".localized }
        else if bank == Bank.bank_17.rawValue { return "bank_17".localized }
        else if bank == Bank.bank_18.rawValue { return "bank_18".localized }
        else if bank == Bank.bank_19.rawValue { return "bank_19".localized }
        else if bank == Bank.bank_20.rawValue { return "bank_20".localized }
        else if bank == Bank.bank_21.rawValue { return "bank_21".localized }
        else if bank == Bank.bank_22.rawValue { return "bank_22".localized }
        else if bank == Bank.bank_23.rawValue { return "bank_23".localized }
        else if bank == Bank.bank_24.rawValue { return "bank_24".localized }
        else if bank == Bank.bank_25.rawValue { return "bank_25".localized }
        else if bank == Bank.bank_26.rawValue { return "bank_26".localized }
        else if bank == Bank.bank_27.rawValue { return "bank_27".localized }
        else if bank == Bank.bank_28.rawValue { return "bank_28".localized }
        else if bank == Bank.bank_29.rawValue { return "bank_29".localized }
        else if bank == Bank.bank_30.rawValue { return "bank_30".localized }
        else if bank == Bank.bank_31.rawValue { return "bank_31".localized }
        else if bank == Bank.bank_32.rawValue { return "bank_32".localized }
        else if bank == Bank.bank_33.rawValue { return "bank_33".localized }
        else if bank == Bank.bank_34.rawValue { return "bank_34".localized }
        else if bank == Bank.bank_35.rawValue { return "bank_35".localized }
        else if bank == Bank.bank_36.rawValue { return "bank_36".localized }
        else if bank == Bank.bank_37.rawValue { return "bank_37".localized }
        else { return bank }
    }
    
    static func severKey(_ bank:String) -> String {
        if bank == "bank_0".localized { return  Bank.bank_0.rawValue}
        else if bank == "bank_1".localized { return Bank.bank_1.rawValue }
        else if bank == "bank_2".localized { return Bank.bank_2.rawValue }
        else if bank == "bank_3".localized { return Bank.bank_3.rawValue }
        else if bank == "bank_4".localized { return Bank.bank_4.rawValue }
        else if bank == "bank_5".localized { return Bank.bank_5.rawValue }
        else if bank == "bank_6".localized { return Bank.bank_6.rawValue }
        else if bank == "bank_7".localized { return Bank.bank_7.rawValue }
        else if bank == "bank_8".localized { return Bank.bank_8.rawValue }
        else if bank == "bank_9".localized { return Bank.bank_9.rawValue }
        else if bank == "bank_10".localized { return Bank.bank_10.rawValue }
        else if bank == "bank_11".localized { return Bank.bank_11.rawValue }
        else if bank == "bank_12".localized { return Bank.bank_12.rawValue }
        else if bank == "bank_13".localized { return Bank.bank_13.rawValue }
        else if bank == "bank_14".localized { return Bank.bank_14.rawValue }
        else if bank == "bank_15".localized { return Bank.bank_15.rawValue }
        else if bank == "bank_16".localized { return Bank.bank_16.rawValue }
        else if bank == "bank_17".localized { return Bank.bank_17.rawValue }
        else if bank == "bank_18".localized { return Bank.bank_18.rawValue }
        else if bank == "bank_19".localized { return Bank.bank_19.rawValue }
        else if bank == "bank_20".localized { return Bank.bank_20.rawValue }
        else if bank == "bank_21".localized { return Bank.bank_21.rawValue }
        else if bank == "bank_22".localized { return Bank.bank_22.rawValue }
        else if bank == "bank_23".localized { return Bank.bank_23.rawValue }
        else if bank == "bank_24".localized { return Bank.bank_24.rawValue }
        else if bank == "bank_25".localized { return Bank.bank_25.rawValue }
        else if bank == "bank_26".localized { return Bank.bank_26.rawValue }
        else if bank == "bank_27".localized { return Bank.bank_27.rawValue }
        else if bank == "bank_28".localized { return Bank.bank_28.rawValue }
        else if bank == "bank_29".localized { return Bank.bank_29.rawValue }
        else if bank == "bank_30".localized { return Bank.bank_30.rawValue }
        else if bank == "bank_31".localized { return Bank.bank_31.rawValue }
        else if bank == "bank_32".localized { return Bank.bank_32.rawValue }
        else if bank == "bank_33".localized { return Bank.bank_33.rawValue }
        else if bank == "bank_34".localized { return Bank.bank_34.rawValue }
        else if bank == "bank_35".localized { return Bank.bank_35.rawValue }
        else if bank == "bank_36".localized { return Bank.bank_36.rawValue }
        else if bank == "bank_37".localized { return Bank.bank_37.rawValue }
        else { return bank }
    }
    
}
enum ConnectionType {
    case answer
    case offer
}
