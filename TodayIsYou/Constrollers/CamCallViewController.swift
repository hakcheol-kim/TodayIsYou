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
    
    private var webRtcClient: WebRTCClient!
    private var signalClient: SignalingClient!
    private var watingTimerVc:CallWaitingTimerViewController!
    
    var data:JSON!
    var connectionType:ConnectionType = .answer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showWatingTimerVc()
        
        self.webRtcClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        if (self.btnSound.isSelected) {
            webRtcClient.speakerOn()
        }
        else {
            webRtcClient.speakerOff()
        }
        webRtcClient.delegate = self
        
        let userName = data["user_name"].stringValue
        let userId = data["user_id"].stringValue
        let soket = WebSocket(url: Config.default.signalingServerUrl)
        signalClient = SignalingClient(connectionType: connectionType, soket, to:userId , userName , roomKey: Utility.roomKeyCam())
        signalClient.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(PUSH_DATA), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.signalClient.connect()
        if connectionType == .offer {
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(PUSH_DATA), object: nil)
    }
    
    func showWatingTimerVc() {
        self.watingTimerVc = CallWaitingTimerViewController.instantiateFromStoryboard {
            self.myRemoveChildViewController(childViewController: self.watingTimerVc)
            var param:[String:Any] = [:]
            param["from_user_id"] =  ShareData.ins.myId
            param["to_user_id"] = self.data["to_user_id"].stringValue
            param["msg"] = "CAM_CANCEL"
            ApiManager.ins.requestRejectPhoneTalk(param: param, success: nil, fail: nil)
            self.navigationController?.popViewController(animated: true)
        }
        myAddChildViewController(superView: self.view, childViewController: watingTimerVc)
    }
    func removeWaitingChildVc() {
        
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
    
    ///MARK::push handler
     override func notificationHandler(_ notification: NSNotification) {
         if notification.name == Notification.Name(PUSH_DATA) {
             guard let info = notification.object as? JSON else {
                 return
             }
             let msg_cmd = info["msg_cmd"].stringValue
             if msg_cmd == "CAM_NO" || msg_cmd == "CAM_CANCEL" {
                 if self.presentedViewController != nil {
                     self.presentedViewController?.dismiss(animated: false, completion: nil)
                 }
                 self.navigationController?.popViewController(animated: true)
             }
         }
     }
}
extension CamCallViewController: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("== webrtc didDiscoverLocalCandidate")
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        print("== webrtc didChangeConnectionState")
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        print("== webrtc didReceiveData")
    }
    
    func webRTCClient(_ client: WebRTCClient, didAdd stream: RTCMediaStream) {
        print("== webrtc didAdd")
    }
    
    func webRTCClient(_ client: WebRTCClient, didRemove stream: RTCMediaStream) {
        print("== webrtc didRemove")
    }
    
    
}

extension CamCallViewController : SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        print("== signal signalClientDidConnect")
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("== signal signalClientDidDisconnect")
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("== signal didReceiveRemoteSdp")
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("== signal didReceiveCandidate")
    }
    
    func signalClientDidReady(_ signalClient: SignalingClient) {
        print("== signal signalClientDidReady")
    }
    
    func signalClientDidRoomOut(_ signalClient: SignalingClient) {
        print("== signal signalClientDidRoomOut")
    }
    
    func signalClientDidToRoomOut(_ signalClient: SignalingClient) {
        print("== signal signalClientDidToRoomOut")
    }
    
    func signalClientDidCallNo(_ signalClient: SignalingClient) {
        print("== signal signalClientDidCallNo")
    }
    
    func signalClientChatMessage(_ signalClient: SignalingClient, msg: String) {
        print("== signal signalClientChatMessage")
    }
   
}
