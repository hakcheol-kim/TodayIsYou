//
//  IntroViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/24.
//

import UIKit

class IntroViewController: UIViewController {
    @IBOutlet weak var ivBg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        //1. 앱캐쉬에 저장되있닌지 찾는다.
        //a52fd10c131f149663a64ab074d5b44b
//        c4f3f037ff94f95fe144fc9aed76f0b6
//        ShareData.ins.dfsSet("c4f3f037ff94f95fe144fc9aed76f0b6", DfsKey.userId)
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
            //키체인에 저장하지 않는다. 로그인화면이 있어 빼버림
            let userIdentifier = KeychainItem.currentUserIdentifier
            if userIdentifier.isEmpty == false {
                let userId = userIdentifier.components(separatedBy: "|").last!
                let md5UserId = Utility.createUserId(userId)
                ShareData.ins.myId = md5UserId
                self.requestUserInfo()
            }
            else {
                self.memberRegiestView()
            }
        }
       
    }
    func memberRegiestView() {
        //회원가입
        if appDelegate.currentLanguage == "ko" {
            let vc = JoinTermsAgreeViewController.instantiateFromStoryboard(.login)!
            let user = ["joinType": "phone"]
            vc.user = user
            appDelegate.window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
            appDelegate.window?.makeKeyAndVisible()
        }
        else {
            appDelegate.callLoginVC()
        }
    }
    //앱타입 변경
    func requestChageAppType() {
        ApiManager.ins.requestChangeAppType(type: appType, userId: ShareData.ins.myId) { res in
            let isSuccess = res["isSuccess"].stringValue
            let Message = res["Message"].stringValue
            if isSuccess == "01" {
                appDelegate.window?.makeToast(Message)
            }
        } fail: { err in
            self.showErrorToast(err)
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
                self.memberRegiestView()
            }
            else if isSuccess == "01" {
                self.requestChageAppType()
                
                let use_yn = response["use_yn"].stringValue
                if use_yn == "N" {
                    let out_diff = response["out_diff"].intValue
                    var msg = ""
                    if out_diff < 15 {
                        msg = String(format: NSLocalizedString("member_rejoin", comment: "재가입 신청은 15일 후에 재가입 가능합니다."), 15-out_diff)
                        let alert = CAlertViewController.init(type: .alert, title: NSLocalizedString("activity_txt537", comment: "재 가입 신청"), message: msg, actions: [.ok]) { vcs, item, index in
                            vcs.dismiss(animated: true, completion: nil)
                            exit(0) //강제 종료
                        }
                        appDelegate.window!.rootViewController!.present(alert, animated: true, completion: nil)
                        alert.btnFullClose.isUserInteractionEnabled = false
                    }
                    else {
                        msg = NSLocalizedString("activity_txt538", comment: "탈퇴 회원입니다.\n재 가입을 하시겠습니까?")
                        let alert = CAlertViewController.init(type: .alert,title: NSLocalizedString("info", comment: "안내"), message: msg, actions: [.cancel, .ok]) { (vcs, item, index) in
                            vcs.dismiss(animated: true, completion: nil)
                            if index == 1 {
                                self.memberRegiestView()
                            }
                        }
                        appDelegate.window!.rootViewController!.present(alert, animated: true, completion: nil)
                        alert.btnFullClose.isUserInteractionEnabled = false
                    }
                }
                else if use_yn == "X" {
                    self.requestCheckUserBlock()
                }
                else if use_yn == "A" {
                    let alert = CAlertViewController.init(type: .alert, message: NSLocalizedString("activity_txt539", comment: "관리자에 의해 차단되었습니다"), actions: [.ok]) { (vcs, selItem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                        exit(0)
                    }
                    appDelegate.window!.rootViewController!.present(alert, animated: true, completion: nil)
                    alert.btnFullClose.isUserInteractionEnabled = false
                }
                else {
                    ShareData.ins.setUserInfo(response)
//                    self.requestPushMessage()
                    appDelegate.callMainViewCtrl()
                    
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
                let blackDay = String(format: NSLocalizedString("block_end_date", comment: "차단이 끝나는 날자는 입니다."), end_date)
                let msg = "\(blackDay)\n\n\(block_memo)"
                let alert = CAlertViewController.init(type:.alert, title: NSLocalizedString("info", comment: "안내"), message: msg, actions:[.ok]) { (vcs, selItem, index) in
                    vcs.dismiss(animated: false, completion: nil)
                    exit(0)
                }
                appDelegate.window!.rootViewController!.present(alert, animated: true, completion: nil)
                alert.btnFullClose.isUserInteractionEnabled = false
            }
            else {
                self.memberRegiestView()
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
}
