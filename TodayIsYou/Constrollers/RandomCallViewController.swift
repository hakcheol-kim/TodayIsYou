//
//  RandomCallViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/05/10.
//

import UIKit
import SwiftyGif
import SwiftyJSON

class RandomCallViewController: BaseViewController {
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var ivLoading: UIImageView!
    
    var timer:Timer? = nil
    let watingSecond: TimeInterval = 10
    var pageNum = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let gif = try UIImage(gifName: "bubble_512.gif")
            self.ivLoading.setGifImage(gif, loopCount: -1)
        }
        catch {
        }
        
        self.requestRandomCallSend()
        self.startTimer()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(rawValue: PUSH_DATA), object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: PUSH_DATA), object: nil)
        self.stopTimer()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnBack {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func startTimer() {
        self.stopTimer()
        self.ivLoading.isHidden = false
        let endTimer = Date.timeIntervalSinceReferenceDate + watingSecond
        let diff:Int = Int(endTimer - Date.timeIntervalSinceReferenceDate)
        let minute = diff/60
        let second = (diff%60)
        let time = String(format: "%02ld:%02ld", minute, second)
        lbTime.text = time
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            let diff:Int = Int(endTimer - Date.timeIntervalSinceReferenceDate)
            if diff < 0 {
                self?.timeOut()
            }
            else {
                let minute = diff/60
                let second = (diff%60)
                let time = String(format: "%02ld:%02ld", minute, second)
                self?.lbTime.text = time
            }
        }
    }
    func stopTimer() {
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        timer.fire()
    }
    func timeOut() {
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        timer.fire()
        self.lbTime.text = "00:00"
        self.ivLoading.isHidden = true
        self.showRandonCallAlert()
    }
    
    func showRandonCallAlert() {
        let vc = CAlertViewController.init(type: .alert, title:NSLocalizedString("random_popup_title", comment: "램덤 영상 채팅 신청"), message: NSLocalizedString("random_popup_msg", comment: "재 신청 시 포인트 소모는 없습니다.\n 재 신청하시겠습니까?"), actions: [.cancel, .ok]) { vcs, selItem, action in
            vcs.dismiss(animated: true, completion: nil)
            if action == 1 {
                self.requestRandomCallSend()
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(vc, animated: true, completion: nil)
        vc.btnFullClose.isUserInteractionEnabled = false
    }
    
    func requestRandomCallSend() {
        var param = [String:Any]()
        param["listNum"] = 20
        param["pageNum"] = pageNum + 1
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_name"] = ShareData.ins.myName
        param["from_user_gender"] = ShareData.ins.mySex.rawValue
        param["from_user_age"] = ShareData.ins.dfsGet(DfsKey.userAge) ?? ""
        param["to_user_gender"] = ShareData.ins.mySex.transGender().rawValue
        param["room_key"] = Utility.roomKeyCam()
        ApiManager.ins.requestRandomCall(param: param) { res in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.startTimer()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    override func notificationHandler(_ notification: NSNotification) {
        if notification.name == Notification.Name(PUSH_DATA) {
            guard let type = notification.object as? PushType else {
                return
            }
            if type == .camNo || type == .camCancel {
                self.stopTimer()
                self.lbTime.text = "00:00"
                self.showRandonCallAlert()
            }
            else if type == .rdCam {
                guard let userInfo = notification.userInfo else {
                    return
                }
                self.dismiss(animated: true, completion: nil)
                
                let info = JSON(userInfo)
                let roomKey = info["room_key"].stringValue
                let toUserId = info["from_user_id"].stringValue
                
                let req = ["user_id":toUserId]
                ApiManager.ins.requestGetUserImgTalk(param: req) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        var data = res
                        data["message_key"] = info["message_key"]
                        data["room_key"] = info["room_key"]
                        data["from_user_id"] = info["from_user_id"]
                        data["msg_cmd"] = "CAM"
                        let toUserName = data["user_name"].stringValue

                        let canCall = appDelegate.checkPoint(callType: .cam, connectedType: .answer)
                      
                        if canCall {
                            let vc = CamCallViewController.initWithType(.answer, roomKey, toUserId, toUserName, data)
                            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: false)
                        }
                        else {
                            appDelegate.showPointLackPopup(callType: .cam)
                        }
    //                    if var obj = data.dictionaryObject {
    //                        obj["read_yn"] = true
    //                        obj["reg_date"] = Date()
    //                        obj["type"] = 1
    //                        DBManager.ins.insertChatMessage(obj, nil)
    //                    }
                    }
                } fail: { (error) in
                    
                }
            }
        }
    }
}
