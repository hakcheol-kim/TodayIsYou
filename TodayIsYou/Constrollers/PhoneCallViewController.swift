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
            let good_cnt = info["good_cnt"].numberValue
            let talk_user_img = info["talk_user_img"].stringValue
            let to_user_contents = info["to_user_contents"].stringValue
            
            ivProfile.image = Gender.defaultImg(user_sex)
            if let url = Utility.thumbnailUrl(toUserId, talk_user_img) {
                ivProfile.setImageCache(url)
                ivProfile.contentMode = .scaleAspectFill
            }
            
            lbTakMsg.text = TalkMemo.localizedString(to_user_contents)
            lbUserName.text = user_name
            lbGender.text = Gender.localizedString(user_sex)
            lbAge.text = Age.localizedString(user_age)
            lbGoodCnt.text = good_cnt.stringValue.addComma()
        }
        
//        기본 60초 600포인트 소모
//        이후 10초당 100포인트가 차감됩니다.
        var phone_out_start_point = "600"
        if let stPoint = ShareData.ins.dfsGet(DfsKey.phoneOutStartPoint) as? NSNumber {
            phone_out_start_point = stPoint.stringValue
        }
        var phone_out_user_point = "100"
        if let usePoint = ShareData.ins.dfsGet(DfsKey.phoneOutUserPoint) as? NSNumber {
            phone_out_user_point = usePoint.stringValue.addComma()
        }
        let msg = NSLocalizedString("activity_txt390", comment: "기본 60초") + " \(phone_out_start_point) \(NSLocalizedString("activity_txt391", comment: "포인트 소모\n이후 10초당")) \(phone_out_user_point) \(NSLocalizedString("activity_txt392", comment: "포인트가 차감됩니다."))"
        lbNotiMsg.text = msg
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
            
            watingTimerVc.message = "\(NSLocalizedString("activity_txt223", comment: "상대가 수락하면 기본 1분")) \(sp) \(NSLocalizedString("activity_txt224", comment: " 포인트 1분 이후 10초에")) \(ep)\(NSLocalizedString("activity_txt213", comment: "포인트 차감됩니다."))"
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
                print("==== 1차 차감 완료: \(response)");
            }
            else {
                print("==== 오류: 1차 차감: \(response)");
            }
        } fail: { error in
            self.showErrorToast(error)
            print("==== 오류: 1차 차감: \(error)");
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
                print("==== 2차 차감 완료: \(response)");
            }
            else {
                print("==== 오류: 2차 차감: \(response)");
            }
        } fail: { error in
            self.showErrorToast(error)
            print("==== 오류: 2차 차감: \(error)");
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
        
        self.signalClient.disconnect()
        self.webRtcClient.close()
        self.requestPaymentEndPoint()
        AppDelegate.ins.showScoreAlert(toUserId: self.toUserId!, toUserName: self.toUserName)
        
        self.completion?()
        self.navigationController?.popViewController(animated: false)
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
                    AppDelegate.ins.window?.makeToast(NSLocalizedString("activity_txt243", comment: "찜등록완료!!"))
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
                    AppDelegate.ins.window?.makeToast(NSLocalizedString("activity_txt429", comment: "좋아요."))
                }
                else if isSuccess == "02" {
                    AppDelegate.ins.window?.makeToast(NSLocalizedString("activity_txt171", comment: "좋아요는 1회만 가능합니다."))
                }
                else {
                    self.showToast(NSLocalizedString("activity_txt173", comment: "등록 에러!!"))
                }
            } fail: { (error) in
                self.showErrorToast(error)
            }
        }
        else if sender == btnOut {
            CAlertViewController.show(type: .alert, title: nil, message: NSLocalizedString("activity_txt402", comment:"통화를 종료합니다"), actions: [.cancel, .ok]) { (vcs, selItem, action) in
                vcs.dismiss(animated: true, completion: nil)
                
                if action == 1 {
                    var param:[String:Any] = [:]
                    param["from_user_id"] =  ShareData.ins.myId
                    param["to_user_id"] = self.toUserId
                    param["msg"] = "CAM_NO"
                    ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
                    self.stopTimer()
                }
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
                if self.presentedViewController != nil {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                self.navigationController?.popViewController(animated: true)
                AppDelegate.ins.window?.makeBottomTost(NSLocalizedString("activity_txt313", comment: "상대가 취소했습니다."))
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
                DispatchQueue.main.async {
                    self.stopTimer()
                }
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
        AppDelegate.ins.window?.makeBottomTost(NSLocalizedString("activity_txt187", comment: "상대의 영상이 종료 되었습니다!!"))
        self.stopTimer()
    }
    
    func signalClientDidToRoomOut(_ signalClient: SignalingClient) {
        print("== signal signalClientDidToRoomOut")
        self.removeWaitingChildVc()
        AppDelegate.ins.window?.makeBottomTost(NSLocalizedString("activity_txt177", comment: "상대가 영상을 종료 했습니다!!"))
        self.stopTimer()
    }
    
    func signalClientDidCallNo(_ signalClient: SignalingClient) {
        print("== signal signalClientDidCallNo")
        self.removeWaitingChildVc()
        AppDelegate.ins.window?.makeBottomTost(NSLocalizedString("activity_txt191", comment: "상대가 영상채팅을 거절 했습니다!!"))
        self.stopTimer()
    }
    
    func signalClientChatMessage(_ signalClient: SignalingClient, msg: String) {
        print("== signal signalClientChatMessage")
        print("msg: \(msg)")
    }
    
}
