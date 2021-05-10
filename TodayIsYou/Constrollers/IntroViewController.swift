//
//  IntroViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/24.
//

import UIKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        //1. 앱캐쉬에 저장되있닌지 찾는다.
//        c4f3f037ff94f95fe144fc9aed76f0b6
        ShareData.ins.dfsSet("c4f3f037ff94f95fe144fc9aed76f0b6", DfsKey.userId)
//            KeychainItem.deleteUserIdentifierFromKeychain()
//            ShareData.ins.dfsRemove(DfsKey.userId)
        #endif
        if let userId = ShareData.ins.dfsGet(DfsKey.userId) as? String, userId.length > 0 {
            //유저 아이디 disk 저장되있는것을 메모리에 올린다.
            ShareData.ins.myId = userId
            self.requestUserInfo()
        }
        else {
            //2. 키체인 영역에 저장된 전화번호 꺼내와 userid 만들어 회원인지 찔러 본다.
            //3. 회원이면 메인, 아니면 로그인 뷰 보냄
            let userIdentifier = KeychainItem.currentUserIdentifier
            if userIdentifier.isEmpty == false {
                let userId = Utility.createUserId(userIdentifier)
                ShareData.ins.myId = userId
                self.requestUserInfo()
            }
            else {
                if let checkPermission = ShareData.ins.dfsGet(DfsKey.checkPermission) as? Bool, checkPermission == true {
                    AppDelegate.ins.callLoginVC()
                }
                else {
                    AppDelegate.ins.callPermissioVc()
                }
            }
        }
    }
    
    //탈퇴회원인지 체크
    func requestUserInfo() {
        if ShareData.ins.myId.isEmpty == true {
            return
        }
        let param = ["app_type": appType, "user_id": ShareData.ins.myId]
        
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "00" {
                AppDelegate.ins.callJoinTermVc()
            }
            else if isSuccess == "01" {
                let use_yn = response["use_yn"].stringValue
                if use_yn == "N" {
                    let out_diff = response["out_diff"].intValue
                    var msg = ""
                    if out_diff < 15 {
                        msg = "재가입 신청은 \(15-out_diff)일 후에 재가입 가능합니다."
                        CAlertViewController.show(type: .alert,title: "안 내", message: msg, actions: [.ok]) { (vcs, item, index) in
                            vcs.dismiss(animated: true, completion: nil)
                            exit(0) //강제 종료
                        }
                    }
                    else {
                        msg = "탈퇴 회원입니다.\n재 가입을 하시겠습니까?"
                        CAlertViewController.show(type: .alert,title: "안 내", message: msg, actions: [.cancel, .ok]) { (vcs, item, index) in
                            vcs.dismiss(animated: true, completion: nil)
                            if index == 1 {
                                AppDelegate.ins.callJoinTermVc()
                            }
                        }
                    }
                }
                else if use_yn == "X" {
                    self.requestCheckUserBlock()
                }
                else if use_yn == "A" {
                    CAlertViewController.show(type: .alert, message: "관리자에 의해 차단되었습니다", actions: [.ok]) { (vcs, selItem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                        exit(0)
                    }
                }
                else {
                    ShareData.ins.setUserInfo(response)
//                    self.requestPushMessage()
                    AppDelegate.ins.callMainViewCtrl()
                    
                }
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    func requestPushMessage() {
        let param = ["app_type":appType, "user_id":ShareData.ins.myId]
        ApiManager.ins.requestPushMessage(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                
            }
            else {
                
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }
    }
    func requestCheckUserBlock() {
        let param = ["user_id":ShareData.ins.myId]
        ApiManager.ins.requestCheckBlockUser(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                let block_memo = res["block_memo"].stringValue
                let end_date = res["end_date"].stringValue
                let msg = "차단이 끝나는 날자는 \(end_date) 입니다.\n\n\(block_memo)"
                CAlertViewController.show(type: .alert, title: "안 내", message: msg, actions:[.ok]) { (vcs, selItem, index) in
                    exit(0)
                }
            }
            else {
                AppDelegate.ins.callJoinTermVc()
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
}
