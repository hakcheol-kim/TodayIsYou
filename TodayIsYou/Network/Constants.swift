//
//  Constants.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import Foundation
import UIKit
let baseUrlNew = "http://todayisyou.co.kr"
//let baseUrl = "http://211.233.15.31:8080"
let baseUrl = "https://api.todayisyou.co.kr"
//let soketUrl = "http://211.233.15.31:8081"
let soketUrl = "http://turn.todayisyou.co.kr:8081"
let rootPath = "api"
let cyberUrl = "https://www.cyber1388.kr:447"
let baseUrl2 = "https://api3.todayisyou.co.kr"
    
//let KCB_CER_URL = "http://www.quizmall.co.kr/cms/kcb_ci/today_app_cnfrm_popup2.php?in_tp_bit=0&hs_cert_rqst_caus_cd=99&form_name=formKcb"
let KCB_CER_URL =  "https://dbdbdeep.com/site19/inc19/kcb_ci/today_app_cnfrm_popup2.php?in_tp_bit=0&hs_cert_rqst_caus_cd=99&form_name=formKcb"

let PICTURE_REGIST_URL = "http://todayisyou.co.kr/app/bb/lookbook.php"
let appType: String = "I1"
let KakaoNativeAppKey = "4ed15923e57b40951d49163ec6250484"

let NAVER_URL_SCHEME = "naverlogin.TodayIsYou"
let NAVER_CONSUMER_KEY = "0tmAza03FIS_QaAub7yc"
let NAVER_CONSUMER_SECRET = "IgI_NBEm42"

let AF_DEV_KEY = "tA3tm3DrvERejW8QgpoTYT" //adflayer devkey
let APPLE_APP_ID = "1564683014"
let today = "otadiyysuo"
let soup = "#8!"
let ivBlockSize = "drowssap20210215"

public func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
public func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 1.0)
}
let randomRowRates = [1, 0.6, 0.6, 0.9, 0.7]
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
    static let check19Plus = "check19Plus"
}
struct CNotiName {
    static let hitTest = "hitTest"
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
            return UIImage(named: "ico_male")
        }
        else {
            return UIImage(named: "ico_female")
        }
    }
    
    static func defaultImgSquare(_ gender:String?) -> UIImage? {
        guard let gender = gender else {
            return nil
        }
        
        if gender == Gender.mail.rawValue {
            return UIImage(named: "ico_male")
        }
        else {
            return UIImage(named: "ico_female")
        }
    }
    static func defaultImg(_ gender:String?) -> UIImage? {
        guard let gender = gender else {
            return nil
        }
        
        if gender == Gender.mail.rawValue {
            return UIImage(named: "ico_male_round")
        }
        else {
            return UIImage(named: "ico_female_round")
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
    case text = "text"
    case image = "image"
}
enum PhotoManageType: Int {
    case normal, cam, talk, photo, profile
}

enum Storyboard: String {
    case main = "Main"
    case login = "Login"
    case call = "Call"
    case other = "Other"
    case picture = "Picture"
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
    case admin = "ADMIN" //전체푸시
    
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
        } else if str  == "ADMIN" {
            return .admin
        }
        else {
            return .empty
        }
    }
}

enum TalkMemo: String {
    case root_display_txt34 = "가입인사드립니다"
    case root_display_txt35 = "재미있게 영상 채팅 해요"
    case root_display_txt36 = "먼저 영상 신청해 주세요"
    case root_display_txt37 = "친구가 필요해요"
    case root_display_txt38 = "동갑 친구가 좋아요"
    case root_display_txt39 = "연하가 좋아요"
    case root_display_txt40 = "연상이 좋아요"
    case root_display_txt41 = "개인기 봐주세요"
    case root_display_txt42 = "심심해요"
    case root_display_txt43 = "재미있게 채팅 해요"
    case root_display_txt44 = "먼저 메세지 주세요"
    case root_display_txt45 = "차 한잔 할까요"
    case root_display_txt46 = "영화 볼까요?"
    case root_display_txt47 = "대화하다 친해지면 만나요"
    case root_display_txt48 = "고민 들어 주세요"
    case root_display_txt49 = "포토톡 해요"
    case root_display_txt50 = "애인이 필요해요"
    
    static func localizedString(_ memo: String) -> String {
        if  memo == TalkMemo.root_display_txt34.rawValue { return "root_display_txt34".localized }
        else if  memo == TalkMemo.root_display_txt35.rawValue { return "root_display_txt35".localized }
        else if  memo == TalkMemo.root_display_txt36.rawValue { return "root_display_txt36".localized }
        else if  memo == TalkMemo.root_display_txt37.rawValue { return "root_display_txt37".localized }
        else if  memo == TalkMemo.root_display_txt38.rawValue { return "root_display_txt38".localized }
        else if  memo == TalkMemo.root_display_txt39.rawValue { return "root_display_txt39".localized }
        else if  memo == TalkMemo.root_display_txt40.rawValue { return "root_display_txt40".localized }
        else if  memo == TalkMemo.root_display_txt41.rawValue { return "root_display_txt41".localized }
        else if  memo == TalkMemo.root_display_txt42.rawValue { return "root_display_txt42".localized }
        else if  memo == TalkMemo.root_display_txt43.rawValue { return "root_display_txt43".localized }
        else if  memo == TalkMemo.root_display_txt44.rawValue { return "root_display_txt44".localized }
        else if  memo == TalkMemo.root_display_txt45.rawValue { return "root_display_txt45".localized }
        else if  memo == TalkMemo.root_display_txt46.rawValue { return "root_display_txt46".localized }
        else if  memo == TalkMemo.root_display_txt47.rawValue { return "root_display_txt47".localized }
        else if  memo == TalkMemo.root_display_txt48.rawValue { return "root_display_txt48".localized }
        else if  memo == TalkMemo.root_display_txt49.rawValue { return "root_display_txt49".localized }
        else if  memo == TalkMemo.root_display_txt50.rawValue { return "root_display_txt50".localized }
        else { return memo }
    }
    static func severKey(_ memo:String) -> String {
        if  memo == "root_display_txt34".localized { return  TalkMemo.root_display_txt34.rawValue}
        else if  memo == "root_display_txt35".localized { return  TalkMemo.root_display_txt35.rawValue }
        else if  memo == "root_display_txt36".localized { return  TalkMemo.root_display_txt36.rawValue }
        else if  memo == "root_display_txt37".localized { return  TalkMemo.root_display_txt37.rawValue }
        else if  memo == "root_display_txt38".localized { return  TalkMemo.root_display_txt38.rawValue }
        else if  memo == "root_display_txt39".localized { return  TalkMemo.root_display_txt39.rawValue }
        else if  memo == "root_display_txt40".localized { return  TalkMemo.root_display_txt40.rawValue }
        else if  memo == "root_display_txt41".localized { return  TalkMemo.root_display_txt41.rawValue }
        else if  memo == "root_display_txt42".localized { return  TalkMemo.root_display_txt42.rawValue }
        else if  memo == "root_display_txt43".localized { return  TalkMemo.root_display_txt43.rawValue }
        else if  memo == "root_display_txt44".localized { return  TalkMemo.root_display_txt44.rawValue }
        else if  memo == "root_display_txt45".localized { return  TalkMemo.root_display_txt45.rawValue }
        else if  memo == "root_display_txt46".localized { return  TalkMemo.root_display_txt46.rawValue }
        else if  memo == "root_display_txt47".localized { return  TalkMemo.root_display_txt47.rawValue }
        else if  memo == "root_display_txt48".localized { return  TalkMemo.root_display_txt48.rawValue }
        else if  memo == "root_display_txt49".localized { return  TalkMemo.root_display_txt49.rawValue }
        else if  memo == "root_display_txt50".localized { return  TalkMemo.root_display_txt50.rawValue }
        else { return memo }
    }
}

enum Age: String {
    case root_display_txt25 = "10대"
    case root_display_txt26 = "20대"
    case root_display_txt27 = "30대"
    case root_display_txt28 = "40대"
    case root_display_txt29 = "50대"
    case root_display_txt30 = "60대"
    case root_display_txt31 = "70대"
    case root_display_txt32 = "80대"
    
    static func localizedString(_ age:String) -> String {
        if age == Age.root_display_txt25.rawValue{ return "root_display_txt25".localized }
        else if age == Age.root_display_txt26.rawValue{ return "root_display_txt26".localized }
        else if age == Age.root_display_txt27.rawValue{ return "root_display_txt27".localized }
        else if age == Age.root_display_txt28.rawValue{ return "root_display_txt28".localized }
        else if age == Age.root_display_txt29.rawValue{ return "root_display_txt29".localized }
        else if age == Age.root_display_txt30.rawValue{ return "root_display_txt30".localized }
        else if age == Age.root_display_txt31.rawValue{ return "root_display_txt31".localized }
        else if age == Age.root_display_txt32.rawValue{ return "root_display_txt32".localized }
        else { return age}
    }
    
    static func severKey(_ age:String) -> String {
        if age == "root_display_txt25".localized { return Age.root_display_txt25.rawValue }
        else if age == "root_display_txt26".localized { return Age.root_display_txt26.rawValue }
        else if age == "root_display_txt27".localized { return Age.root_display_txt27.rawValue }
        else if age == "root_display_txt28".localized { return Age.root_display_txt28.rawValue }
        else if age == "root_display_txt29".localized { return Age.root_display_txt29.rawValue }
        else if age == "root_display_txt30".localized { return Age.root_display_txt30.rawValue }
        else if age == "root_display_txt31".localized { return Age.root_display_txt31.rawValue }
        else if age == "root_display_txt32".localized { return Age.root_display_txt32.rawValue }
        else { return age }
    }
}

enum Area: String {
    case root_display_txt01 = "전체"
    case root_display_txt02 = "서울"
    case root_display_txt03 = "부산"
    case root_display_txt04 = "대구"
    case root_display_txt05 = "인천"
    case root_display_txt06 = "광주"
    case root_display_txt07 = "대전"
    case root_display_txt08 = "울산"
    case root_display_txt09 = "경기"
    case root_display_txt10 = "강원"
    case root_display_txt11 = "충북"
    case root_display_txt12 = "충남"
    case root_display_txt13 = "전북"
    case root_display_txt14 = "전남"
    case root_display_txt15 = "경북"
    case root_display_txt16 = "경남"
    case root_display_txt17 = "제주"
    case root_display_txt18 = "해외"
    
    
    static func localizedString(_ area:String) -> String {
        if area == Area.root_display_txt01.rawValue { return "root_display_txt01".localized }
        else if area == Area.root_display_txt02.rawValue { return "root_display_txt02".localized }
        else if area == Area.root_display_txt03.rawValue { return "root_display_txt03".localized }
        else if area == Area.root_display_txt04.rawValue { return "root_display_txt04".localized }
        else if area == Area.root_display_txt05.rawValue { return "root_display_txt05".localized }
        else if area == Area.root_display_txt06.rawValue { return "root_display_txt06".localized }
        else if area == Area.root_display_txt07.rawValue { return "root_display_txt07".localized }
        else if area == Area.root_display_txt08.rawValue { return "root_display_txt08".localized }
        else if area == Area.root_display_txt09.rawValue { return "root_display_txt09".localized }
        else if area == Area.root_display_txt10.rawValue { return "root_display_txt10".localized }
        else if area == Area.root_display_txt11.rawValue { return "root_display_txt11".localized }
        else if area == Area.root_display_txt12.rawValue { return "root_display_txt12".localized }
        else if area == Area.root_display_txt13.rawValue { return "root_display_txt13".localized }
        else if area == Area.root_display_txt14.rawValue { return "root_display_txt14".localized }
        else if area == Area.root_display_txt15.rawValue { return "root_display_txt15".localized }
        else if area == Area.root_display_txt16.rawValue { return "root_display_txt16".localized }
        else if area == Area.root_display_txt17.rawValue { return "root_display_txt17".localized }
        else if area == Area.root_display_txt18.rawValue { return "root_display_txt18".localized }
        else { return area }
    }
    
    static func severKey(_ area: String) -> String {
        if area == "root_display_txt01".localized { return Area.root_display_txt01.rawValue}
        else if area == "root_display_txt02".localized { return  Area.root_display_txt02.rawValue }
        else if area == "root_display_txt03".localized { return  Area.root_display_txt03.rawValue }
        else if area == "root_display_txt04".localized { return  Area.root_display_txt04.rawValue }
        else if area == "root_display_txt05".localized { return  Area.root_display_txt05.rawValue }
        else if area == "root_display_txt06".localized { return  Area.root_display_txt06.rawValue }
        else if area == "root_display_txt07".localized { return  Area.root_display_txt07.rawValue }
        else if area == "root_display_txt08".localized { return  Area.root_display_txt08.rawValue }
        else if area == "root_display_txt09".localized { return  Area.root_display_txt09.rawValue }
        else if area == "root_display_txt10".localized { return  Area.root_display_txt10.rawValue }
        else if area == "root_display_txt11".localized { return  Area.root_display_txt11.rawValue }
        else if area == "root_display_txt12".localized { return  Area.root_display_txt12.rawValue }
        else if area == "root_display_txt13".localized { return  Area.root_display_txt13.rawValue }
        else if area == "root_display_txt14".localized { return  Area.root_display_txt14.rawValue }
        else if area == "root_display_txt15".localized { return  Area.root_display_txt15.rawValue }
        else if area == "root_display_txt16".localized { return  Area.root_display_txt16.rawValue }
        else if area == "root_display_txt17".localized { return  Area.root_display_txt17.rawValue }
        else if area == "root_display_txt18".localized { return  Area.root_display_txt18.rawValue }
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

enum ScrollDirection {
    case none, up, down
}
func degreesToRadian(_ angle: Double) ->Double {
    return (angle/180.0) * .pi
}
