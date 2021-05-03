//
//  CamCallViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/23.
//

import UIKit
import SwiftyJSON
import WebRTC

class CamCallViewController: BaseViewController {
    
    @IBOutlet weak var lbTalkTime: UILabel!
    @IBOutlet weak var locaVideo: UIView!
    @IBOutlet weak var mainVideo: UIView!
    @IBOutlet weak var btnSound: CButton!
    @IBOutlet weak var btnCamera: CButton!
    @IBOutlet weak var btnGift: CButton!
    @IBOutlet weak var btnAddUser: CButton!
    @IBOutlet weak var btnLike: CButton!
    @IBOutlet weak var btnMicroPhone: CButton!
    @IBOutlet weak var lbCost: UILabel!
    
    
    var speakerOn:Bool = true
    
    private var watingTimerVc:CallWaitingTimerViewController!
    
    private lazy var signalClient: SignalingClient = {
        var client = SignalingClient(connectionType: connectionType, WebSocket(url: Config.default.signalingServerUrl), to: toUserId, toUserName, roomKey: self.roomKey)
        client.delegate = self
        return client
    }()
    
    private lazy var webRtcClient: WebRTCClient = {
        var client = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        if self.speakerOn {
            client.speakerOn()
        }
        client.delegate = self
        return client
    }()
    
    
    private var signalingConnected: Bool = false
    private var hasLocalSdp: Bool = false
    private var localCandidateCount: Int = 0
    
    private var hasRemoteSdp: Bool = false
    private var remoteCandidateCount: Int = 0
    private var timer: Timer?
    
    var tapVideoView:UIView!
    
    var roomKey:String!
    var toUserId:String!
    var toUserName:String!
    var info:JSON?
    var connectionType:ConnectionType = .answer
    
    var second: TimeInterval = 0.0 {
        didSet {
            if second == 0.0 {
                lbTalkTime.text = "--:--"
                return
            }
            let min = Int(second / 60)
            let sec = Int(second) % 60
            lbTalkTime.text = String(format: "%02ld:%02ld", min, sec)
            let num = NSNumber.init(integerLiteral: Int(second*15))
            let strMoney = num.toString()
            if strMoney.isEmpty == false {
                lbCost.text = "₩\(num.toString())"
            }
            else {
                lbCost.text = ""
            }
        }
    }
    
    static func initWithType(_ type:ConnectionType, _ roomKey:String, toUserId:String, toUserName:String?, info:JSON? = nil) -> CamCallViewController {
        let vc = CamCallViewController.instantiateFromStoryboard(.call)!
        vc.roomKey = roomKey
        vc.toUserId = toUserId
        vc.toUserName = toUserName
        vc.info = info
        vc.connectionType = type
        return vc
    }
    
    //MARK:: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        second = 0.0
        self.tapVideoView = locaVideo
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(PUSH_DATA), object: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.signalClient.connect()
        self.configureVideoRenderer()
        if connectionType == .offer {
            self.showWatingTimerVc()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(PUSH_DATA), object: nil)
        self.stopTimer()
        removeWaitingChildVc()
    }
    
    private func configureVideoRenderer() {
        #if arch(arm64)
        // Using metal (arm64 only)
        let localRenderer = RTCMTLVideoView(frame: self.locaVideo.frame)
        let remoteRenderer = RTCMTLVideoView(frame: self.mainVideo.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        #else
        // Using OpenGLES for the rest
        let localRenderer = RTCEAGLVideoView(frame: self.locaVideo.frame)
        let remoteRenderer = RTCEAGLVideoView(frame: self.mainVideo.frame)
        #endif

        self.webRtcClient.startCaptureLocalVideo(renderer: localRenderer)
        self.webRtcClient.renderRemoteVideo(to: remoteRenderer)
        
        self.embedView(localRenderer, into: self.locaVideo)
        self.embedView(remoteRenderer, into: self.mainVideo)
//        self.view.sendSubviewToBack(remoteRenderer)
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
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
        myAddChildViewController(superView: self.view, childViewController: watingTimerVc)
    }
    func startTimer() {
        self.stopTimer()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] timer in
            self?.second += 1
        })
    }
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            timer.fire()
        }
    }
    func removeWaitingChildVc() {
        if let childVc = watingTimerVc {
            self.myRemoveChildViewController(childViewController: childVc)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
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
            }
            AppDelegate.ins.window?.makeBottomTost("상대가 취소했습니다.")
        }
    }
}
extension CamCallViewController: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("== webrtc didDiscoverLocalCandidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        print("== webrtc didChangeConnectionState")
        
        var textColor = UIColor.label
        switch state {
        case .connected, .completed:
            textColor = .green
            break
        case .disconnected:
            textColor = .orange
            break
        case .failed:
            textColor = .red
            break
        case .new, .checking, .count:
            textColor = .purple
        default:
            break
        }
        
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
    
}

extension CamCallViewController : SignalClientDelegate {
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
        AppDelegate.ins.window?.makeBottomTost("상대가 채팅방을 나갔습니다.")
    }
    
    func signalClientDidToRoomOut(_ signalClient: SignalingClient) {
        print("== signal signalClientDidToRoomOut")
        self.removeWaitingChildVc()
        AppDelegate.ins.window?.makeBottomTost("상대가 신청을 취소했습니다.")
    }
    
    func signalClientDidCallNo(_ signalClient: SignalingClient) {
        print("== signal signalClientDidCallNo")
        self.removeWaitingChildVc()
        AppDelegate.ins.window?.makeBottomTost("상대가 영상채팅을 거절 했습니다.")
    }
    
    func signalClientChatMessage(_ signalClient: SignalingClient, msg: String) {
        print("== signal signalClientChatMessage")
        print(msg)
    }
   
}
