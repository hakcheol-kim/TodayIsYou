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
        
        self.underReviewIos()
    }
    private func underReviewIos() {
        //검수 및 운영구분    text : 검수버전 / image : 운영버전
        ApiClient.ins.requestJSON(.underReviewIos) { response in
            let code = response["code"].stringValue
            let type = response["type"].stringValue
            if code == "000" {
                ShareData.ins.isReview = (type == "text")
            }
            self.mainProcess()
        } failure: { error in
            guard let error = error, let msg = error.errorDescription else { return }
            self.view.makeToast(msg)
        }
    }
    private func mainProcess() {
#if DEBUG
        //MARK:: 회원가입 프로세스
        // 1순위 userdefault 저장된 userid 있는지
        // 2순위 keychain 저장된 userid 있는지
        // 3순위 userid 있으면 메인 페이지, 없으면 서버 19금 인증 할거냐 조회 후 회원가입

        //1. 앱캐쉬에 저장되있닌지 찾는다.
        //a52fd10c131f149663a64ab074d5b44b
        //        c4f3f037ff94f95fe144fc9aed76f0b6
        //fe7b06372229b4972a8fe90b660fb6e0 화보
//        ShareData.ins.dfsSet("a32d30f0af5a1a1540cbc8430b013146", DfsKey.userId) //01010041004

//        KeychainItem.deleteUserIdentifierFromKeychain()
//        ShareData.ins.dfsRemove(DfsKey.userId)
//        ShareData.ins.dfsRemove(DfsKey.check19Plus)
//        ShareData.ins.dfsSet("a52fd10c131f149663a64ab074d5b44b", DfsKey.userId)
//        ShareData.ins.dfsSet("8cb61f6bef3c749f70a1416abe9b6a3d", DfsKey.userId) //안드로이드 폰
#endif
        
        if let userId = ShareData.ins.dfsGet(DfsKey.userId) as? String, userId.length > 0 {
            //유저 아이디 usdrdefault 저장되있는것을 메모리에 올린다.
            ShareData.ins.myId = userId
            self.requestUserInfo()
        }
        else {
            //2. 키체인 영역에 저장된 전화번호 꺼내와 userid 만들어 회원인지 찔러 본다.
            //3. 회원이면 메인, 아니면 회원가입으로
            //키체인에 저장하지 않는다. 로그인화면이 있어 빼버림
            let userIdentifier = KeychainItem.currentUserIdentifier
            if userIdentifier.isEmpty == false {
                let userId = userIdentifier.components(separatedBy: "|").last!
                let md5UserId = Utility.createUserId(userId)
                ShareData.ins.myId = md5UserId
                self.requestUserInfo()
            }
            else {
                self.showMemberRegistProcess()
            }
        }
    }
    // MARK: - 성인인증 팝업
    private func showAdultCertification() {
        let vc = CertificationWebViewController.instantiateFromStoryboard(.other)!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        vc.didFinish = {(result) ->(Void) in
            if result {
                self.callJoinMemberTermVc()
            }
            else {
                self.mainProcess()
            }
        }
    }
    
    private func showMemberRegistProcess() {
        //회원가입
        //먼저 19금 서버 체크 여부
        if appDelegate.currentLanguage == "ko" {
            if let _ = ShareData.ins.dfsGet(DfsKey.check19Plus) {
                self.callJoinMemberTermVc()
            }
            else {
                self.serverAdultCheck { [weak self] result in
                    guard let self = self else { return }
                    if (result) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                            let audltView = AdultPopupView.init(type: 1)
                            CAlertView.showCustomView(audltView, [audltView.btnExit, audltView.btnRegist]) { index in
                                print("index : \(index)")
                                if index == 0 {
                                    exit(0)
                                }
                                else {
                                    if result {
                                        self.showAdultCertification()
                                    }
                                    else {
                                        ShareData.ins.dfsSet(true, DfsKey.check19Plus)
                                        self.callJoinMemberTermVc()
                                    }
                                }
                            }
                        }
                    }
                    else {
                        self.callJoinMemberTermVc()
                    }
                }
            }
        }
        else {
            appDelegate.callLoginVC()
        }
    }
    
    private func callJoinMemberTermVc() {
        if let checkPermission = ShareData.ins.dfsGet(DfsKey.checkPermission) as? Bool, checkPermission == true {
            let vc = JoinTermsAgreeViewController.instantiateFromStoryboard(.login)!
            let user = ["joinType": "phone"]
            vc.user = user
            appDelegate.window?.rootViewController = BaseNavigationController.init(rootViewController: vc)
            appDelegate.window?.makeKeyAndVisible()
        }
        else {
            appDelegate.callPermissioVc()
        }
    }
}

extension IntroViewController {
    //탈퇴회원인지 체크
    private func requestUserInfo() {
        if ShareData.ins.myId.isEmpty == true {
            return
        }
        let param = ["app_type": appType, "user_id": ShareData.ins.myId]
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "00" {
                self.showMemberRegistProcess()
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
                                self.showMemberRegistProcess()
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
                    if let checkPermission = ShareData.ins.dfsGet(DfsKey.checkPermission) as? Bool, checkPermission == true {
                        appDelegate.callMainViewCtrl()
                    }
                    else {
                        appDelegate.callPermissioVc()
                    }
                }
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    private func requestCheckUserBlock() {
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
                self.showMemberRegistProcess()
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    //앱타입 변경
    private func requestChageAppType() {
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
    //서버 성인인증 체크 여부
    private func serverAdultCheck(_ comps:@escaping(_ result: Bool) -> Void) {
        //통신
        ApiClient.ins.request(.adultCheck, CommonResModel.self) { result in
            if result.code == "000" {
                comps(true)
            }
            else {
                comps(false)
            }
        } failure: { error in
            comps(false)
        }
    }
}
