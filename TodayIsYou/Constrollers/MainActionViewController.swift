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
            self.showToast(NSLocalizedString("activity_txt01", comment: "본인입니다."))
            return
        }
        if user_sex == ShareData.ins.mySex.rawValue {
            self.showToast(NSLocalizedString("activity_txt03", comment: "같은 성별은 영상 채팅이 불가능합니다!!"))
            return
        }
        if status == "Y" {
            self.showToast(NSLocalizedString("activity_txt04", comment: "영상 채팅 중입니다"))
            return
        }
        self.checkAvaiableCamTalk(user_id) { (user) in
            self.selUser = user
            if  self.isBlocked && self.isMyBlock {
                self.showToast(NSLocalizedString("both_black_list", comment: "쌍방이 차단했습니다!!"))
            }
            else if self.isBlocked {
                self.showToast(NSLocalizedString("activity_txt339", comment: "상대가 차단 했습니다!!"))
            }
            else if self.isMyBlock {
                self.showToast(NSLocalizedString("activity_txt219", comment: "내가 차단 했습니다!!"))
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
                self.showToast(NSLocalizedString("both_black_list", comment: "쌍방이 차단했습니다!!"))
            }
            else if self.isBlocked {
                self.showToast(NSLocalizedString("activity_txt339", comment: "상대가 차단 했습니다!!"))
            }
            else if self.isMyBlock {
                self.showToast(NSLocalizedString("activity_txt219", comment: "내가 차단 했습니다!!"))
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
                self.actionAlertPhoneCall()
            }
            else if index == 2 {
                self.actionAlertCamTalkCall()
            }
        }
        
        vc.addCustomView(customView)
        customView.configurationData(selUser)
        vc.iconImgName = customView.getImgUrl()
        vc.aletTitle = customView.getTitleAttr()
        
        if ShareData.ins.mySex.rawValue == "남" {
            if isMyFriend {
                customView.lbMsg1.text = NSLocalizedString("activity_txt215", comment: "대화 목록에 있는 상대는 신청이 무료입니다")
                customView.lbMsg2.isHidden = true
            }
            else {
                customView.lbMsg2.isHidden = false
                var camPoint = "0"
                var phonePoint = "0"
                
                if let p1 = ShareData.ins.dfsGet(DfsKey.camOutUserPoint) as? NSNumber, let p2 = ShareData.ins.dfsGet(DfsKey.phoneOutUserPoint) as? NSNumber {
                    camPoint = p1.stringValue.addComma()
                    phonePoint = p2.stringValue.addComma()
                }
                customView.lbMsg1.text = NSLocalizedString("activity_txt212", comment: "영상 음성 채팅 신청시") + " \(0)" + NSLocalizedString("activity_txt213", comment: "포인트가 차감 됩니다.")
            }
        }
        else {
            customView.lbMsg2.isHidden = true
            customView.lbMsg1.text = NSLocalizedString("activity_txt216", comment: "무료로 이용 가능합니다.")
        }
        vc.reloadUI()
        customView.btnReport.addTarget(self, action: #selector(actionAlertReport(_ :)), for: .touchUpInside)
        vc.btnIcon.addTarget(self, action: #selector(actionAlertProfile), for: .touchUpInside)
        vc.addAction(.cancel, NSLocalizedString("activity_txt479", comment: "취소"), UIImage(systemName: "xmark.circle.fill"), RGB(216, 216, 216))
        vc.addAction(.ok, NSLocalizedString("activity_txt210", comment: "음성"), UIImage(systemName: "phone.fill.arrow.up.right"), RGB(230, 100, 100))
        vc.addAction(.ok, NSLocalizedString("activity_txt211", comment: "영상"), UIImage(systemName: "arrow.up.right.video.fill"), RGB(230, 100, 100))
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func actionAlertProfile(_ sender: UIButton) {
        if let presentedVc = presentedViewController {
            presentedVc.dismiss(animated: false, completion: nil)
        }
//        guard let imgUrl = sender.accessibilityValue else {
//            return
//        }
//        self.showPhoto(imgUrls: [imgUrl])
        let vc = RankDetailViewController.instantiateFromStoryboard(.main)!
        vc.passData = self.selUser
        AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
    }
    @objc private func actionAlertReport(_ sender: UIButton) {
        if let presentedVc = presentedViewController {
            presentedVc.dismiss(animated: false, completion: nil)
        }
        self.actionBlockAlert()
    }
    
    //overide method
    func actionAlertPhoneCall() {
        var param:[String:Any] = [:]
        param["room_key"] = Utility.roomKeyPhone()
        
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_sex"] = ShareData.ins.mySex.rawValue
        param["to_user_id"] = self.selUser["user_id"].stringValue
        param["to_user_name"] = self.selUser["user_name"].stringValue
        param["friend_mode"] = "N"
        
        if isMyFriend {
            param["friend_mode"] = "Y"
        }
        
        ApiManager.ins.requestPhoneCallInsertMsg(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                let to_user_name = res["to_user_name"].stringValue
                let to_user_id = res["to_user_id"].stringValue
                let room_key = res["room_key"].stringValue
                let vc = PhoneCallViewController.initWithType(.offer, room_key, to_user_id, to_user_name, self.selUser)
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }
    }
    func actionAlertCamTalkCall() {
        var param:[String:Any] = [:]
        param["room_key"] = Utility.roomKeyCam()
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_sex"] = ShareData.ins.mySex.rawValue
        param["to_user_id"] = self.selUser["user_id"].stringValue
        param["to_user_name"] = self.selUser["user_name"].stringValue
        param["friend_mode"] = "N"
        
        if isMyFriend {
            param["friend_mode"] = "Y"
        }
        
        ApiManager.ins.requestCamCallInsertMsg(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                let to_user_name = res["to_user_name"].stringValue
                let to_user_id = res["to_user_id"].stringValue
                let room_key = res["room_key"].stringValue
                let vc = CamCallViewController.initWithType(.offer, room_key, to_user_id, to_user_name, self.selUser)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }
    }
    func actionBlockAlert() {
        let user_name = self.selUser["user_name"].stringValue
        let user_id = self.selUser["user_id"].stringValue
        
        var title = ""
        if ShareData.ins.languageCode == "ko" {
            title = "\(user_name)님 \(NSLocalizedString("activity_txt495", comment: "신고하기"))"
        }
        else {
            title = "\(user_name) \(NSLocalizedString("activity_txt495", comment: "신고하기"))"
        }
        
        let alert = CAlertViewController.init(type: .alert, title: title, message: nil, actions: [.cancel, .ok]) { (vcs, selItem, index) in
            
            if (index == 1) {
                guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                    return
                }
                vcs.dismiss(animated: true, completion: nil)
                let param = ["user_name":user_name, "to_user_id":user_id, "user_id":ShareData.ins.myId, "memo":text]
                ApiManager.ins.requestReport(param: param) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        self.showToast(NSLocalizedString("activity_txt246", comment: "신고 완료"))
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } failure: { (error) in
                    self.showErrorToast(error)
                }
            }
            else {
                vcs.dismiss(animated: true, completion: nil)
            }
        }
        alert.iconImg = UIImage(named: "warning")
        alert.addTextView(NSLocalizedString("activity_txt497", comment: "신고내용"), UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        self.present(alert, animated: true, completion: nil)
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
    func presentTalkMsgAlert() {
        
        var attr: NSMutableAttributedString? = nil
        if let bbsPoint = ShareData.ins.dfsGet(DfsKey.talkMsgOutPoint) as? NSNumber, bbsPoint.intValue > 0 {
            let msg1 = NSLocalizedString("activity_txt333", comment: "쪽지 전송은 기본") + " \(bbsPoint.stringValue)" + NSLocalizedString("activity_txt213", comment: "포인트가 차감 됩니다.")
            let msg2 = NSLocalizedString("activity_txt335", comment: "")
            let result = "\(msg1)\n\(msg2)"
            
            attr = NSMutableAttributedString.init(string: result)
            attr!.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, result.length))
            attr!.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: (result as NSString).range(of: msg2))
            attr!.addAttribute(.foregroundColor, value: UIColor.label, range: NSMakeRange(0, msg1.length))
            attr!.addAttribute(.foregroundColor, value: RGB(125, 125, 125), range: (result as NSString).range(of: msg2))
        }
    
        let alert = CAlertViewController.init(type: .alert, title: NSLocalizedString("activity_txt332", comment: "메세지 전송"), message: attr, actions: [.cancel, .ok]) { (vcs, selItem, index)  in
            
            if index == 1 {
                guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                    self.showToast(NSLocalizedString("activity_txt202", comment: "내용을 입력해주세요."))
                    return
                }
                self.requestSendMsg(text)
                vcs.dismiss(animated: true, completion: nil)
            }
            else {
                vcs.dismiss(animated: true, completion: nil)
            }
        }
        alert.lbMsgTextAligment = .natural
        alert.iconImg = UIImage(systemName: "envelope.fill")
        alert.addTextView(NSLocalizedString("activity_txt202", comment: "내용을 입력해주세요."))
        alert.reloadUI()
        
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            alert.arrTextView.first?.becomeFirstResponder()
        }
    }
    
    func requestSendMsg(_ content:String) {
        var param:[String:Any] = [:]
            
        var friend_mode = "N"
        if isMyFriend {
            friend_mode = "Y"
        }
        var bbsPoint = 0
        if let p = ShareData.ins.dfsGet(DfsKey.userBbsPoint) as? NSNumber {
            bbsPoint = p.intValue
        }
        param["user_id"] = ShareData.ins.myId
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_sex"] = ShareData.ins.mySex.rawValue
        param["to_user_id"] = self.selUser["user_id"].stringValue
        param["to_user_name"] = self.selUser["user_name"].stringValue
        param["memo"] = content
        param["user_bbs_point"] = bbsPoint
        param["point_user_id"] = ShareData.ins.myId
        param["friend_mode"] = friend_mode
        
        ApiManager.ins.requestSendTalkMsg(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "00" {
                let errorCode = res["errorCode"].stringValue
                if errorCode == "0002" {
                    self.showToast(NSLocalizedString("activity_txt328", comment: "탈퇴한 회원 입니다"))
                }
                else if errorCode == "0003" {
                    self.showToast(NSLocalizedString("activity_txt329", comment: "차단 상태인 회원 입니다"))
                }
                else {
                    self.showToast(NSLocalizedString("activity_txt86", comment: "오류!!"))
                }
            }
            else {
                self.showToast(NSLocalizedString("activity_txt331", comment: "쪽지 전송 완료"))
                let message_key = res["message_key"].stringValue
                let memo = res["memo"].stringValue
                
                var param:[String:Any] = [:]
                param["message_key"] = message_key
                param["from_user_id"] = ShareData.ins.myId
                param["to_user_id"] = self.selUser["user_id"].stringValue
                param["point_user_id"] = self.selUser["point_user_id"].stringValue
                param["out_chat_point"] = self.selUser["out_chat_point"].stringValue
                param["memo"] = memo
                
                param["file_name"] = res["file_name"].stringValue
                param["reg_date"] = Date()
                param["read_yn"] = true
                param["type"] = 1
                
                DBManager.ins.insertChatMessage(param, nil)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }

}
