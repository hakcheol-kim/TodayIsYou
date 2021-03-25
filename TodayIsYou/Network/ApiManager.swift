//
//  ApiManager.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/09.
//

import UIKit
import Foundation
import Alamofire

class ApiManager: NSObject {
    static let ins = ApiManager()
    
    
    func clientPara(_ param:[String:Any]) -> [String:Any] {
        return ["clientPara":param]
    }

    /// 영상토크리스트
    ///- search_sex: 남, 여, 빈값  search_list: text, image
    func requestCamTalkList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/imgTalkList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///토크리스트
    ///- search_area: 서울, search_sex: 여
    func requestTalkList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/talkAreaList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///포토리스트
    ///- search_photo_top: 인기, 최신, search_photo_sex: 여, 남,
    func requestPhotoList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/photoTalkList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///랭킹리스트
    ///- search_sex: 여 (나의 성별의 반대), user_id:
    func requestRankingList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getRanking.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///쪽지리스트
    ///- user_id: , pageNum
    func requestMsgList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/myMsgList.do", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///찜목록
    ///- user_id: , pageNum
    func requestMyFriendsList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/myFriendList.do", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///차단목록리스트
    ///- user_id: , pageNum
    func requestMyBlockList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/myBlackList.do", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///차단목록리스트
    ///- user_id:
    func requestMssageAllDelete(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/messageAllDelete.do", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///푸쉬키 등록
    /// - fcm_token:
    func requestReigstPushToken(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getFcmCnt.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///푸쉬키 및 유저 정보 업데이트
    /// - fcm_token: , user_id
    func requestUpdatePushTokenAndUserId(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/updateToken.do", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///나의정보가져오기
    /// - user_id
    func requestUerInfo(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getUserInfo.json",  clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///나의정보 업데이트
    /// - user_id, user_name, user_age, user_name_new
    func requestUpdateUerInfo(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/updateUser.do", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///나의 포토 가져오기
    /// - user_id,
    func requestGetMyPhotos(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getMyPhoto.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///나의 프로필 등록
    /// - user_id, image_profile_reservation: true, image_cam_reservation: true, image_talk_reservation: true
    func requestRegistPhoto(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/myPhotoWrite.json", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///약관
    /// - mode: yk1(가입약관), yk2(개인정보취급방침), yk3(환급신청약관)
    func requestServiceTerms(mode:String, success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/yk.do", ["mode": mode], URLEncoding.queryString) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 공지사항 리스트
    ///- user_id
    func requestNoticeList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/noticeList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 공지사항 상세
    ///- seq: notice시퀀스
    func requestNoticeDetail(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getNotice.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 회원 출석체크
    ///- user_point_type: day_login_point, user_id: ,  now_date: yyy-MM-dd
    func requestCheckAttendance(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/loginCheck.do", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 포인트 내역
    ///- user_id:
    func requestMyPList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getMyPList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 별 적립 및 소모내역
    ///- user_id:
    func requestMyRList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getMyRList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 별 환급 목록
    ///- user_id:, pageNum
    func requestMyMoneyList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/myMoneyList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 별 환급 요청
    ///- user_id:
    func requestExchangeCoinToMoney(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getR.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 신고하기
    ///- user_id:, to_user_id:, to_user_name, memo: o - 설정에서 입력<br/>ㅇ
    func requestDeclareToUser(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/insertReport.do", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// Q&A 고객센터 문의
    ///- user_id:
    func requestQnaList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/qandaList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    func requestQnaWrite(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/insertQna.do", param, URLEncoding.queryString) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    func requestGetUserList(param:[String:Any],  success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/userList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    func requestGetPoint(param:[String:Any],  success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getPoint.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    //블락리스트
    func requestGetBlockList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/getBlackList.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    func requestCheckMyFriend(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/talk/myFriendCheck.json", clientPara(param)) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
}
