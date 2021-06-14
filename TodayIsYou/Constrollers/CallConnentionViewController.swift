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
    @IBOutlet weak var btnVideoCall: CButton!
    @IBOutlet weak var btnPhoneCall: PulseButton!
    @IBOutlet weak var ivBgView: UIImageView!
    
    var data:JSON!
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
        btnPhoneCall.layer.cornerRadius = btnPhoneCall.bounds.height/2
        
        if let data = data {
            lbCamTalkMsg.text = data["contents"].stringValue
            lbNickName.text = data["user_name"].stringValue
            lbAge.text = data["user_age"].stringValue
            lbHartCnt.text = data["good_cnt"].stringValue
            let user_id = data["user_id"].stringValue
            let user_img = data["user_img"].stringValue
            
            ivProfile.image = Gender.defaultImg(data["user_sex"].stringValue)
            
            if let url = Utility.thumbnailUrl(user_id, user_img) {
                ivProfile.setImageCache(url)
            }
        }
        self.btnPhoneCall.clipsToBounds = false
        self.btnPhoneCall.isAnimated = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(rawValue: PUSH_DATA), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: PUSH_DATA), object: nil)
        btnPhoneCall.isAnimated = false
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnClose {
            var param:[String:Any] = [:]
            param["from_user_id"] =  ShareData.ins.myId
            param["to_user_id"] = data["from_user_id"].stringValue
            param["msg"] = "CAM_NO"
            ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
            
            self.dismiss(animated: true, completion: nil)
        }
        else if sender == btnVideoCall {
            let user_name = data["user_name"].stringValue
            let room_key = data["room_key"].stringValue
            let from_user_id = data["from_user_id"].stringValue
            
            let canCall = AppDelegate.ins.checkPoint(callType: .cam, connectedType: .answer)
          
            if canCall {
                let vc = CamCallViewController.initWithType(.answer, room_key, from_user_id , user_name, data)
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
            else {
                AppDelegate.ins.showPointLackPopup(callType: .cam)
            }
        }
        else if sender == btnPhoneCall {
            let canCall = AppDelegate.ins.checkPoint(callType: .phone, connectedType: .answer)
            if canCall {
                let user_name = data["user_name"].stringValue
                let room_key = data["room_key"].stringValue
                let from_user_id = data["from_user_id"].stringValue
                let vc = PhoneCallViewController.initWithType(.answer, room_key, from_user_id , user_name, data)
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
            else {
                AppDelegate.ins.showPointLackPopup(callType: .phone)
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
                self.dismiss(animated: true, completion: nil)
            }
            AppDelegate.ins.window?.makeBottomTost("상대가 취소했습니다.")
        }
    }
}
