//
//  MainActionViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/05.
//

import UIKit
import SwiftyJSON

class MainActionViewController: BaseViewController {
    
    let group = DispatchGroup.init()
    let queue = DispatchQueue.global()
    
    var isBlocked = false
    var isMyFriend = false
    var isMyBlock = false
    public var selUser:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func checkCamTalk() {
        let user_sex = selUser["user_sex"].stringValue
        let status = selUser["status"].stringValue
        let user_id = selUser["user_id"].stringValue
        
        if user_id == ShareData.ins.myId {
            self.showToast("본인입니다.")
            return
        }
        if user_sex == ShareData.ins.mySex.rawValue {
            self.showToast("같은 성별은 영상 채팅이 불가능합니다!!")
            return
        }
        if status == "Y" {
            self.showToast("영상 채팅 중입니다")
            return
        }
        self.checkAvaiableCamTalk(user_id) { (user) in
            self.selUser = user
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
    public func checkTalk() {
        let user_id = selUser["user_id"].stringValue
        self.checkAvaiableTalkMsg(user_id) {
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
    private func checkAvaiableCamTalk(_ toUserId:String, _ completion:@escaping(_ selUser:JSON) ->Void) {
        self.getUserInfo(toUserId: toUserId)    //score 별점때문에 호출 안호출 하고 싶은데 별점 스코어 정보가 리스트에 없음
        self.getBlackList(toUserId: toUserId)
        self.getMyBlockList(toUserId: toUserId)
        self.getMyFriendCheck(toUserId: toUserId)
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                completion(self.selUser)
            }
        }
        print("job enter finished")
    }
    
    private func presentCamTalkAlert() {
        let customView = Bundle.main.loadNibNamed("CamTalkAlertView", owner: nil, options: nil)?.first as! CamTalkAlertView
        
        let vc = CAlertViewController.init(type: .custom, title: "", message: nil, actions: nil) { (vcs, selItem, index) in
            vcs.dismiss(animated: true, completion: nil)
            if index == 1 {
                print("음성")
                self.actionAlertPhoneCall()
            }
            else if index == 2 {
                print("영상")
                self.actionAlertCamTalkCall()
            }
        }
        
        vc.addCustomView(customView)
        customView.configurationData(selUser)
        vc.iconImgName = customView.getImgUrl()
        vc.aletTitle = customView.getTitleAttr()
        
        if ShareData.ins.mySex.rawValue == "남" {
            if isMyFriend {
                customView.lbMsg1.text = "대화 목록에 있는 상대는 신청이 무료입니다"
                customView.lbMsg2.isHidden = true
            }
            else {
                customView.lbMsg2.isHidden = false
                var camPoint = "0"
                var phonePoint = "0"
                
                if let p1 = ShareData.ins.dfsObjectForKey(DfsKey.camOutUserPoint) as? NSNumber, let p2 = ShareData.ins.dfsObjectForKey(DfsKey.phoneOutUserPoint) as? NSNumber {
                    camPoint = p1.stringValue.addComma()
                    phonePoint = p2.stringValue.addComma()
                }
                customView.lbMsg1.text = "영상 음성 채팅 신청시 \(0) 포인트가 차감 됩니다."
            }
        }
        else {
            customView.lbMsg2.isHidden = true
            customView.lbMsg1.text = "무료로 이용 가능합니다."
        }
        vc.reloadUI()
        customView.btnReport.addTarget(self, action: #selector(actionAlertReport(_ :)), for: .touchUpInside)
        vc.btnIcon.addTarget(self, action: #selector(actionAlertProfile), for: .touchUpInside)
        vc.addAction(.cancel, "취소", UIImage(systemName: "xmark.circle.fill"), RGB(216, 216, 216))
        vc.addAction(.ok, "음성", UIImage(systemName: "phone.fill.arrow.up.right"), RGB(230, 100, 100))
        vc.addAction(.ok, "영상", UIImage(systemName: "arrow.up.right.video.fill"), RGB(230, 100, 100))
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func actionAlertProfile(_ sender: UIButton) {
        if let presentedVc = presentedViewController {
            presentedVc.dismiss(animated: false, completion: nil)
        }
        guard let imgUrl = sender.accessibilityValue else {
            return
        }
        self.showPhoto(imgUrls: [imgUrl])
    }
    @objc private func actionAlertReport(_ sender: UIButton) {
        if let presentedVc = presentedViewController {
            presentedVc.dismiss(animated: false, completion: nil)
        }
        self.actionBlockAlert()
    }
    public func actionAlertPhoneCall() {
        
    }
    public func actionAlertCamTalkCall() {
        
    }
    public func actionBlockAlert() {
        
    }
    
    public func checkAvaiableTalkMsg(_ toUserId:String, _ completion:@escaping () ->Void) {
        
        self.getBlackList(toUserId: toUserId)
        self.getMyBlockList(toUserId: toUserId)
        self.getMyFriendCheck(toUserId: toUserId)
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                completion()
            }
        }
        print("job enter finished")
    }
    
    public func checkAvaiableChatting(_ toUserId:String, _ completion:@escaping ()-> Void) {
        self.getBlackList(toUserId: toUserId)
        self.getMyBlockList(toUserId: toUserId)
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                completion()
            }
        }
        print("job enter finished")
    }
    //내가 차단한 리스트
    private func getMyBlockList(toUserId:String) {
        group.enter()
        self.isMyBlock = false
        let prama = ["black_user_id":toUserId, "user_id": ShareData.ins.myId]
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
        let prama = ["black_user_id" : ShareData.ins.myId, "user_id" : toUserId]
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
        let param = ["from_user_id": ShareData.ins.myId, "to_user_id":toUserId]
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
            self.selUser = response
            self.group.leave()
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
        }
    }
    
    //talk overide method
    public func presentTalkMsgAlert() {
        
    }
   
}
