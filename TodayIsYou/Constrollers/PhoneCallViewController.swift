//
//  PhoneCallViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/29.
//

import UIKit
import WebRTC
import UIImageViewAlignedSwift
import SwiftyJSON
class PhoneCallViewController: MainActionViewController {

    @IBOutlet weak var btnOut: CButton!
    @IBOutlet weak var lbTakeTime: UILabel!
    @IBOutlet weak var ivProfile: UIImageViewAligned!
    @IBOutlet weak var btnSpeaker: CButton!
    @IBOutlet weak var btnMyFriend: CButton!
    @IBOutlet weak var btnLike: CButton!
    @IBOutlet weak var lbTakMsg: UILabel!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbGender: UILabel!
    @IBOutlet weak var lbGoodCnt: UILabel!
    @IBOutlet weak var lbAge: UILabel!
    @IBOutlet weak var lbNotiMsg: UILabel!
    
    private var watingTimerVc:CallWaitingTimerViewController!
    var roomKey: String!
    var toUserId: String!
    var toUserName: String!
    var info: JSON?
    var connectionType: ConnectionType = .answer
    var completion:(() ->Void)?
    var baseStartPoint = 0
    var baseLivePoint = 0
    private lazy var signalClient: SignalingClient = {
        var client = SignalingClient(connectionType: connectionType, WebSocket(url: Config.default.signalingServerUrl), to: toUserId, toUserName, roomKey: self.roomKey)
        client.delegate = self
        return client
    }()
    
    private lazy var webRtcClient: WebRTCClient = {
        var client = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        client.speakerOn()
        client.delegate = self
        return client
    }()
    
    let colorGreen = RGB(195, 255, 91)
    let colorPurple = RGB(237, 109, 151)
    let colorTint = UIColor.black
    var nowPoint:Int = 0
    var timer:Timer?
    var second: TimeInterval = 0.0 {
        didSet {
            if second == 0.0 {
                lbTakeTime.text = "00:00:00"
                return
            }
            
            var min = Int(second / 60)
            let hour = Int(min/60)
            let sec = Int(second) % 60
            min = min % 60
            
            lbTakeTime.text = String(format: "%02ld:%02ld:%02ld", hour, min, sec)
        }
    }
    
    private var signalingConnected: Bool = false
    private var hasLocalSdp: Bool = false
    private var localCandidateCount: Int = 0
    private var hasRemoteSdp: Bool = false
    private var remoteCandidateCount: Int = 0
    
    static func initWithType(_ type:ConnectionType, _ roomKey:String, _ toUserId:String, _ toUserName:String?, _ info:JSON? = nil, _ completion:(() ->Void)? = nil) -> PhoneCallViewController {
        let vc = PhoneCallViewController.instantiateFromStoryboard(.call)!
        vc.roomKey = roomKey
        vc.toUserId = toUserId
        vc.toUserName = toUserName
        vc.info = info
        vc.connectionType = type
        vc.completion = completion
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        btnOut.imageView?.contentMode = .scaleAspectFit
        
        nowPoint = ShareData.ins.myPoint?.intValue ?? 0
        
        lbTakMsg.text = ""
        lbUserName.text = ""
        lbGender.text = ShareData.ins.mySex.transGender().rawValue
        lbAge.text = ""
        lbGoodCnt.text = "0"
        if let startPoint = ShareData.ins.dfsGet(DfsKey.phoneOutStartPoint) as? NSNumber, startPoint.intValue > 0 {
            baseStartPoint = startPoint.intValue
        }
        if let livePoint = ShareData.ins.dfsGet(DfsKey.phoneOutUserPoint) as? NSNumber, livePoint.intValue > 0 {
            baseLivePoint = livePoint.intValue
        }

        if let info = info {
            let user_name = info["user_name"].stringValue
            let user_age = info["user_age"].stringValue
            let user_sex = info["user_sex"].stringValue
            let good_cnt = info["good_cnt"].stringValue
            let talk_user_img = info["talk_user_img"].stringValue
            let to_user_contents = info["to_user_contents"].stringValue
            
            ivProfile.image = Gender.defaultImg(user_sex)
            if let url = Utility.thumbnailUrl(toUserId, talk_user_img) {
                ivProfile.setImageCache(url)
                ivProfile.contentMode = .scaleAspectFill
            }
            
            lbTakMsg.text = to_user_contents
            lbUserName.text = user_name
            lbGender.text = user_sex
            lbAge.text = user_age
            lbGoodCnt.text = good_cnt.addComma()
        }
        
        self.signalClient.connect()
//        self.configureVideoRenderer()
        if connectionType == .offer {
            self.showWatingTimerVc()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(PUSH_DATA), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        NotificationCenter.default.removeObserver(self, name: Notification.Name(PUSH_DATA), object: nil)
        self.stopTimer()
        removeWaitingChildVc()
    }
    
    private func showWatingTimerVc() {
        self.watingTimerVc = CallWaitingTimerViewController.instantiateFromStoryboard {
            self.myRemoveChildViewController(childViewController: self.watingTimerVc)
            var param:[String:Any] = [:]
            param["from_user_id"] =  ShareData.ins.myId
            param["to_user_id"] = self.toUserId
            param["msg"] = "CAM_CANCEL"
            
            ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
            self.navigationController?.popViewController(animated: true)
        }
        if ShareData.ins.mySex.rawValue == "남" {
            let sp = "\(baseStartPoint)".addComma()
            let ep = "\(baseLivePoint)".addComma()
            watingTimerVc.message = "상대가 수락하면 기본 1분 \(sp)포인트 1분 이후 10초에 \(ep)포인트 차감됩니다."
        }
        watingTimerVc.type = .phone
        myAddChildViewController(superView: self.view, childViewController: watingTimerVc)
    }
    
    func requestPaymentStartPoint() {
        var param = [String:Any]()
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_sex"] = ShareData.ins.mySex.rawValue
        param["to_user_id"] = toUserId!
        param["out_point"] = baseStartPoint
        param["room_key"] = roomKey!
        
        ApiManager.ins.requestPhoneCallPaymentStartPoint(param: param) { response in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                print("phone start point payment success: \(response)");
            }
            else {
                print("phone start point payment error");
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func requestPaymentEndPoint() {
        var param = [String:Any]()
        
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_sex"] = ShareData.ins.mySex.rawValue
        param["to_user_id"] = toUserId!
        param["out_point_time"] = (Int(second)/10)*baseLivePoint
        param["room_key"] = roomKey!
        ApiManager.ins.requestPhoneCallPaymentEndPoint(param: param) { response in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                print("phone end point payment success: \(response)");
                AppDelegate.ins.showScoreAlert(toUserId: self.toUserId!, toUserName: self.toUserName)
            }
            else {
                print("phone end point payment fail");
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    func startTimer() {
        if let timer = timer {
            timer.invalidate()
            timer.fire()
        }
        self.requestPaymentStartPoint()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] timer in
            self?.second += 1
        })
    }
    func stopTimer() {
        guard let timer = self.timer else {
            return
        }
        
        timer.invalidate()
        timer.fire()
        self.timer = nil
        self.requestPaymentEndPoint()
    }
    
    func removeWaitingChildVc() {
        if let childVc = watingTimerVc {
            self.myRemoveChildViewController(childViewController: childVc)
        }
    }
   
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSpeaker {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                webRtcClient.speakerOn()
                btnSpeaker.tintColor = colorGreen
                btnSpeaker.backgroundColor = colorTint
            }
            else {
                self.webRtcClient.speakerOff()
                btnSpeaker.tintColor = colorTint
                btnSpeaker.backgroundColor = colorGreen
            }
        }
        else if sender == btnMyFriend {
            let param = ["user_id": toUserId!, "user_name": toUserName!, "my_id": ShareData.ins.myId]
            
            ApiManager.ins.requestSetMyFried(param: param) { res in
                let isSuccess = res["isSuccess"].stringValue
                if isSuccess == "01" {
                    self.showToast("찜 등록 되었습니다.")
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
        else if sender == btnLike {
            let param = ["user_id": toUserId! as Any, "my_user_id": ShareData.ins.myId]
            ApiManager.ins.requesetUpdateGood(param: param) { (res) in
                let isSuccess = res["isSuccess"].stringValue
                if isSuccess == "01" {
                    self.showToast("좋아요.")
                }
                else if isSuccess == "02" {
                    self.showToast("좋아요는 1회만 가능합니다.")
                }
                else {
                    self.showErrorToast(res)
                }
            } fail: { (error) in
                self.showErrorToast(error)
            }
        }
        else if sender == btnOut {
            CAlertViewController.show(type: .alert, title: nil, message: "음성 통화를 종료합니다.", actions: [.cancel, .ok]) { (vcs, selItem, action) in
                vcs.dismiss(animated: true, completion: nil)
                
                if action == 1 {
                    var param:[String:Any] = [:]
                    param["from_user_id"] =  ShareData.ins.myId
                    param["to_user_id"] = self.toUserId
                    param["msg"] = "CAM_NO"
                    ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
                    self.actionPopviewCtrl()
                }
            }
        }
    }
    
    func actionPopviewCtrl() {
        self.navigationController?.popViewController(animated: false)
        self.completion?()
    }
    
    ///MARK::push handler
    override func notificationHandler(_ notification: NSNotification) {
        if notification.name == Notification.Name(PUSH_DATA) {
            guard let type = notification.object as? PushType, let _ = notification.userInfo as? [String:Any] else {
                return
            }
            
            if type == .camNo || type == .camCancel {
                self.stopTimer()
                
                if self.presentedViewController != nil {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                self.navigationController?.popViewController(animated: true)
                AppDelegate.ins.window?.makeBottomTost("상대가 취소했습니다.")
            }
        }
    }
}
///MARK: WebRTCClientDelegate
extension PhoneCallViewController: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didReceiveLocalVideoTrack videoTrack: RTCVideoTrack) {
        
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        print("== webrtc didReceiveData")
        
        guard let msg = String(data:data, encoding: .utf8) else {
            return
        }
        DispatchQueue.main.async {
            self.showToast(msg)
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didAdd stream: RTCMediaStream) {
        print("== webrtc didAdd")
        DispatchQueue.main.async {
            self.startTimer()
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didRemove stream: RTCMediaStream) {
        print("== webrtc didRemove")
        DispatchQueue.main.async {
            self.stopTimer()
        }
    }
    
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("== webrtc didDiscoverLocalCandidate")
//        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        print("== webrtc didChangeConnectionState")
        DispatchQueue.main.async {
            var textColor = UIColor.label
            switch state {
            case .connected, .completed:
                textColor = .green
                AppDelegate.ins.window?.makeToast("수락")
                break
            case .disconnected:
                textColor = .orange
//                AppDelegate.ins.window?.makeToast("연결 끊김")
                break
            case .failed:
                textColor = .red
//                AppDelegate.ins.window?.makeToast("실패")
                break
            case .new, .checking, .count:
                textColor = .purple
            default:
                break
            }
        }
    }
}
///MARK:: SignalClientDelegate
extension PhoneCallViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        print("== signal signalClientDidConnect")
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("== signal signalClientDidDisconnect")
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("== signal didReceiveRemoteSdp")
        self.webRtcClient.set(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
            self.webRtcClient.answer { sdp in
                self.signalClient.send(type: "answer", sdp: sdp)
            }
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("== signal didReceiveCandidate")
        self.remoteCandidateCount += 1
        self.webRtcClient.set(remoteCandidate: candidate)
    }
    
    func signalClientDidReady(_ signalClient: SignalingClient) {
        print("== signal signalClientDidReady")
        self.webRtcClient.offer { sdp in
            self.hasLocalSdp = true
            self.signalClient.send(type: "offer", sdp: sdp)
        }
        self.removeWaitingChildVc()
    }
    
    func signalClientDidRoomOut(_ signalClient: SignalingClient) {
        print("== signal signalClientDidRoomOut")
        self.removeWaitingChildVc()
        AppDelegate.ins.window?.makeBottomTost("상대가 영상채팅 신청을 취소 했습니다!!")
        self.stopTimer()
        actionPopviewCtrl()
    }
    
    func signalClientDidToRoomOut(_ signalClient: SignalingClient) {
        print("== signal signalClientDidToRoomOut")
        self.removeWaitingChildVc()
        AppDelegate.ins.window?.makeBottomTost("상대의 영상이 종료 되었습니다!!")
        self.stopTimer()
        actionPopviewCtrl()
    }
    
    func signalClientDidCallNo(_ signalClient: SignalingClient) {
        print("== signal signalClientDidCallNo")
        self.removeWaitingChildVc()
        AppDelegate.ins.window?.makeBottomTost("상대가 영상채팅을 거절 했습니다.")
        self.stopTimer()
        actionPopviewCtrl()
    }
    
    func signalClientChatMessage(_ signalClient: SignalingClient, msg: String) {
        print("== signal signalClientChatMessage")
        print("msg: \(msg)")
    }
    
}
