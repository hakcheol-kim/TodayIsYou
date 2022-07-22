//
//  CallReceiveWatingViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/27.
//

import UIKit
import SwiftyJSON

class CallConnentionViewController: BaseViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbCamTalkMsg: UILabel!
    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var lbAge: UILabel!
    @IBOutlet weak var lbHartCnt: UILabel!
    @IBOutlet weak var btnVideoCall: UIButton!
    @IBOutlet weak var btnPhoneCall: PulseButton!
    @IBOutlet weak var ivBgView: UIImageView!
    
    var connectedType : ConnectionType = .answer
    var toUserId: String = ""
    var roomKey: String = ""
    var toUser: ImgTalkResModel!
    
    static func initWithType(_ type: ConnectionType, roomKey: String, toUserId: String) -> CallConnentionViewController {
        let vc = CallConnentionViewController.instantiateFromStoryboard(.call)!
        vc.connectedType = type
        vc.roomKey = roomKey
        vc.toUserId = toUserId
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        let random = NSInteger.random(in: 1..<7)
        let imgName = "img_back\(random)"
        let filePath = Bundle.main.path(forResource: imgName, ofType: "jpg")!
        ivBgView.image = UIImage(contentsOfFile: filePath)
        
        btnVideoCall.imageView?.contentMode = .scaleAspectFit
        btnPhoneCall.imageView?.contentMode = .scaleAspectFit
        btnVideoCall.layer.cornerRadius = btnVideoCall.bounds.size.height/2
        btnPhoneCall.layer.cornerRadius = btnPhoneCall.bounds.height/2
        
        self.initUi()
        self.requestToUserInfo()
        //self.btnVideoCall.isAnimated = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(rawValue: PUSH_DATA), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: PUSH_DATA), object: nil)
        btnPhoneCall.isAnimated = false
    }
    
    private func requestToUserInfo() {
        let req = ["user_id": toUserId]
        ApiManager.ins.requestGetUserImgTalk(param: req) { (res) in
            do {
                if let toUser = try ImgTalkResModel.decode(data: res.rawData()),
                   toUser.isSuccess == "01" {
                    self.toUser = toUser
                    self.setupUi()
                }
                else {
                    self.showErrorToast(res)
                }
            } catch {
                print("imagetalk decode error")
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }
    }
    private func initUi() {
        lbCamTalkMsg.text = ""
        lbNickName.text = ""
        lbAge.text = ""
        lbHartCnt.text = ""
        ivProfile.image = nil
    }
    private func setupUi() {
        lbCamTalkMsg.text = toUser.contents
        lbNickName.text = toUser.user_name
        lbAge.text = toUser.user_age
        lbHartCnt.text = "\(toUser.good_cnt)".addComma()
        ivProfile.image = Gender.defaultImg(toUser.user_sex)
        
        if let url = Utility.thumbnailUrl(toUserId, toUser.user_img) {
            ivProfile.setImageCache(url)
        }
        
        self.btnPhoneCall.clipsToBounds = false
        self.btnPhoneCall.isAnimated = true
        self.btnVideoCall.clipsToBounds = false
    }
    
    private func closeVC() {
        if let navigationVc = self.navigationController {
            navigationVc.popViewController(animated: false)
        }
        else {
            self.dismiss(animated: false)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnClose {
            var param:[String:Any] = [:]
            param["from_user_id"] =  ShareData.ins.myId
            param["to_user_id"] = toUserId
            param["msg"] = "CAM_NO"
            ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
            closeVC()
        }
        else if sender == btnVideoCall {
            var param:[String:Any] = [:]
            param["from_user_id"] =  ShareData.ins.myId
            param["to_user_id"] = toUserId
            param["msg"] = "CAM_NO"
            ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
            
            closeVC()
        }
        else if sender == btnPhoneCall {
            print("videocall =========================> ")
            let canCall = appDelegate.checkPoint(callType: .cam, connectedType: self.connectedType)
          
            if canCall {
                var param:[String:Any] = [:]
                param["room_key"] = roomKey
                param["from_user_id"] = ShareData.ins.myId  //from_user_id
                param["from_user_sex"] = ShareData.ins.mySex   //from_user_sex
                param["to_user_id"] =  toUserId
                param["to_user_name"] = toUser.user_name
//                param["friend_mode"] = "N"
                
                ApiManager.ins.requestRandomCamCallInsertMsg(param: param) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        let vc = CamCallViewController.initWithType(.offer, roomKey:self.roomKey, toUserId: self.toUserId)
                        appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } fail: { (error) in
                    self.showErrorToast(error)
                }
            }
            else {
                appDelegate.showPointLackPopup(callType: .cam)
            }
        }
    }
    
   ///MARK::push handler
    override func notificationHandler(_ notification: NSNotification) {
        if notification.name == Notification.Name(PUSH_DATA) {
            guard let type = notification.object as? PushType, let _ = notification.userInfo as? [String:Any] else {
                return
            }
            
            if type == .camNo || type == .camCancel {
                closeVC()
            }
            print("여기 1")
            appDelegate.window?.makeBottomTost("상대가 취소했습니다.")
        }
    }
    
}
