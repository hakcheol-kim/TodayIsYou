//
//  MainActionViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/05.
//

import UIKit
import SwiftyJSON

class MainActionViewController: BaseViewController {
    var selectedUser:JSON!
    
    let group = DispatchGroup.init()
    let queue = DispatchQueue.global()
    var isMyBlock = false
    var isBlocked = false
    var isMyFriend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public func checkAvaiableCamTalk() {
        guard let selectedUser = selectedUser else {
            return
        }
        let user_sex = selectedUser["user_sex"].stringValue
        let status = selectedUser["status"].stringValue
        let user_id = selectedUser["user_id"].stringValue
        
        if user_id == ShareData.ins.userId {
            self.showToast("본인입니다.")
            return
        }
        if user_sex == ShareData.ins.userSex.rawValue {
            self.showToast("같은 성별은 영상 채팅이 불가능합니다!!")
            return
        }
        if status == "Y" {
            self.showToast("영상 채팅 중입니다")
            return
        }
    
        let toUserId = selectedUser["user_id"].stringValue
        
        self.getUserInfo(toUserId: toUserId)
        self.getBlackList(toUserId: toUserId)
        self.getMyBlockList(toUserId: toUserId)
        self.getMyFriendCheck(toUserId: toUserId)
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                if  self.isBlocked && self.isMyBlock {
                    self.showToast("쌍방이 차단했습니다!!")
                }
                else if self.isBlocked {
                    self.showToast("상대가 차단 했습니다!!")
                }
                else if self.isMyBlock {
                    self.showToast("내가 차단 했습니다!!")
                }
                else {
                    self.presentCamTalkAlert()
                }
            }
        }
        print("job enter finished")
    }
    
    public func checkAvaiableTalkMsg() {
        guard let selectedUser = selectedUser else {
            return
        }
        
        let toUserId = selectedUser["user_id"].stringValue
        
        self.getBlackList(toUserId: toUserId)
        self.getMyBlockList(toUserId: toUserId)
        self.getMyFriendCheck(toUserId: toUserId)
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                if  self.isBlocked && self.isMyBlock {
                    self.showToast("쌍방이 차단했습니다!!")
                }
                else if self.isBlocked {
                    self.showToast("상대가 차단 했습니다!!")
                }
                else if self.isMyBlock {
                    self.showToast("내가 차단 했습니다!!")
                }
                else {
                    self.presentTalkMsgAlert()
                }
            }
        }
        print("job enter finished")
    }
    
    //내가 차단한 리스트
    private func getMyBlockList(toUserId:String) {
        group.enter()
        self.isMyBlock = false
        let prama = ["black_user_id":toUserId, "user_id": ShareData.ins.userId]
        ApiManager.ins.requestGetBlockList(param: prama) { (response) in
            self.group.leave()
            if response["isSuccess"].stringValue == "01" {
                let black_list_cnt = response["black_list_cnt"].intValue
                if black_list_cnt > 0 {
                    self.isMyBlock = true
                }
            }
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
        }
    }
    //상대방이 차단
    private func getBlackList(toUserId:String) {
        group.enter()
        self.isBlocked = false
        let prama = ["black_user_id" : ShareData.ins.userId, "user_id" : toUserId]
        ApiManager.ins.requestGetBlockList(param: prama) { (response) in
            self.group.leave()
            if response["isSuccess"].stringValue == "01" {
                let black_list_cnt = response["black_list_cnt"].intValue
                if black_list_cnt > 0 {
                    self.isBlocked = true
                }
            }
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
        }
    }
    private func getMyFriendCheck(toUserId:String) {
        group.enter()
        self.isMyFriend = false
        let param = ["from_user_id": ShareData.ins.userId, "to_user_id":toUserId]
        ApiManager.ins.requestCheckMyFriend(param: param) { (response) in
            self.group.leave()
            if response["isSuccess"].stringValue == "01" {
                let friendCnt = response["friendCnt"].intValue
                if friendCnt > 0 {
                    self.isMyFriend = true
                }
            }
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
        }
    }
    private func getUserInfo(toUserId:String) {
        self.group.enter()
        let param = ["app_type": appType, "user_id":toUserId]
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            self.selectedUser["user_score"] = response["user_score"]
            self.group.leave()
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
        }
    }
    public func presentCamTalkAlert() {
        
    }
    public func presentTalkMsgAlert() {
        
    }
   
}
