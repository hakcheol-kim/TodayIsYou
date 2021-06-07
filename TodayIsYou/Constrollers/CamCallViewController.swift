//
//  CamCallViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/23.
//

import UIKit
import SwiftyJSON
import WebRTC
class MessageCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbMsg: UILabel!
    
    static let identifier = "MessageCell"
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
} 
class CamCallViewController: BaseViewController {
    @IBOutlet weak var baseVideoView: UIView!
    @IBOutlet weak var locaVideo: UIView!
    @IBOutlet weak var mainVideo: UIView!
    
    @IBOutlet weak var lbTalkTime: UILabel!
    @IBOutlet weak var btnSpeaker: CButton!
    @IBOutlet weak var btnCamera: CButton!
    @IBOutlet weak var btnMsg: CButton!
    @IBOutlet weak var btnGift: CButton!
    @IBOutlet weak var btnMyFriend: CButton!
    @IBOutlet weak var btnLike: CButton!
    @IBOutlet weak var btnMicroPhone: CButton!
    @IBOutlet weak var lbCost: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblView: UITableView!
    
    var baseStartPoint = 0
    var baseLivePoint = 0
    var phoneOutStartPoint = 0 // 최소 포인트
    
    var nowPoint:Int = 0 {
        didSet {
            if nowPoint < 0 && ShareData.ins.mySex == .mail {
                self.sendMessage("Room Out")
                if let timer = self.timer {
                    timer.invalidate()
                    timer.fire()
                    self.timer = nil
                }
                self.signalClient.disconnect()
                self.webRtcClient.close()
                self.navigationController?.popViewController(animated: false)
                self.showPointLakePopup()
            }
        }
    }

    var listData:[String] = []
    var originListData:[String] = []
    var speakerOn:Bool = true
    var targetVideoView:UIView?
    let colorGreen = RGB(195, 255, 91)
    let colorPurple = RGB(237, 109, 151)
    
    private var watingTimerVc:CallWaitingTimerViewController!
    
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
    
    private var signalingConnected: Bool = false
    private var hasLocalSdp: Bool = false
    private var localCandidateCount: Int = 0
    private var hasRemoteSdp: Bool = false
    private var remoteCandidateCount: Int = 0
    
    private var timer: Timer?
    
    var roomKey:String!
    var toUserId:String!
    var toUserName:String!
    var info:JSON?
    var connectionType:ConnectionType = .answer
    var completion:(() ->Void)?
    var sPoint = CGPoint.zero
    
    var second: TimeInterval = 0.0 {
        didSet {
            if second == 0.0 {
                lbTalkTime.text = "00:00:00"
                return
            }
            
            var min = Int(second / 60)
            let hour = Int(min/60)
            let sec = Int(second) % 60
            min = min % 60
            
            lbTalkTime.text = String(format: "%02ld:%02ld:%02ld", hour, min, sec)
            
            var checkPoint:Int = Int(second - 60) //처음 1분은 빼고 계산
            if checkPoint < 0 {
                checkPoint = 0
            }
            checkPoint = Int(checkPoint/10)
            self.nowPoint = nowPoint - checkPoint*self.baseLivePoint
        }
    }
    
    static func initWithType(_ type:ConnectionType, _ roomKey:String, _ toUserId:String, _ toUserName:String?, _ info:JSON? = nil, _ completion:(() ->Void)? = nil) -> CamCallViewController {
        let vc = CamCallViewController.instantiateFromStoryboard(.call)!
        vc.roomKey = roomKey
        vc.toUserId = toUserId
        vc.toUserName = toUserName
        vc.info = info
        vc.connectionType = type
        vc.completion = completion
        return vc
    }
    
    //MARK:: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        second = 0.0
        nowPoint = ShareData.ins.myPoint?.intValue ?? 0
//        #if DEBUG
//        nowPoint = 100
//        #endif
        lbCost.text = ""
        if let startPoint = ShareData.ins.dfsGet(DfsKey.camOutStartPoint) as? NSNumber, startPoint.intValue > 0 {
            baseStartPoint = startPoint.intValue
        }
        if let livePoint = ShareData.ins.dfsGet(DfsKey.camOutUserPoint) as? NSNumber, livePoint.intValue > 0 {
            baseLivePoint = livePoint.intValue
        }
        if let outStartPoint = ShareData.ins.dfsGet(DfsKey.camOutStartPoint) as? NSNumber, outStartPoint.intValue > 0 {
            phoneOutStartPoint = outStartPoint.intValue
        }
        
        locaVideo.accessibilityValue = "S"
        mainVideo.accessibilityValue = "L"
        
        self.signalClient.connect()
        self.configureVideoRenderer()
        if connectionType == .offer {
            self.showWatingTimerVc()
        }
        
        sPoint = CGPoint(x: 16, y: (baseVideoView.safeAreaInsets.top+locaVideo.bounds.width/2))

        locaVideo.translatesAutoresizingMaskIntoConstraints = false
        mainVideo.translatesAutoresizingMaskIntoConstraints = false
    
        tblView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tblView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(PUSH_DATA), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.removeObserver(self, name: Notification.Name(PUSH_DATA), object: nil)
        removeWaitingChildVc()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func showPointLakePopup() {
        let title = NSLocalizedString("activity_txt451", comment: "포인트가 부족 합니다.")
        var point = nowPoint
        if (point < 0) {
            point = 0
        }
        let msg = "\(point) \(NSLocalizedString("activity_txt449", comment: "포인트가 남아 있습니다.\n최소")) \(self.phoneOutStartPoint)  \(NSLocalizedString("activity_txt450", comment: "포인트가 필요 합니다."))"
        
        let vc = CAlertViewController.init(type: .alert,title: title, message: msg, actions: nil) { vcs, selItem, action in
            vcs.dismiss(animated: true, completion: nil)
            
            if action == 1 {
                let pointVc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
                AppDelegate.ins.mainNavigationCtrl.pushViewController(pointVc, animated: true)
            }
        }
        vc.addAction(.cancel, NSLocalizedString("activity_txt479", comment: "취소"))
        vc.addAction(.ok, NSLocalizedString("activity_txt452", comment: "충전"))
        AppDelegate.ins.window?.rootViewController?.present(vc, animated: false, completion: nil)
    }
    private func configureVideoRenderer() {
        #if arch(arm64)
       let localRenderer = RTCMTLVideoView(frame: self.locaVideo.frame)
        let remoteRenderer = RTCMTLVideoView(frame: self.mainVideo.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        #else
        let localRenderer = RTCEAGLVideoView(frame: self.locaVideo.frame)
        let remoteRenderer = RTCEAGLVideoView(frame: self.mainVideo.frame)
        #endif

        self.webRtcClient.startCaptureLocalVideo(renderer: localRenderer)
        self.webRtcClient.renderRemoteVideo(to: remoteRenderer)
        
        self.embedView(localRenderer, into: self.locaVideo)
        self.embedView(remoteRenderer, into: self.mainVideo)
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
        if ShareData.ins.mySex.rawValue == "남" {
            let sp = "\(baseStartPoint)".addComma()
            let ep = "\(baseLivePoint)".addComma()
            watingTimerVc.message = "\(NSLocalizedString("activity_txt223", comment: "상대가 수락하면 기본 1분")) \(sp) \(NSLocalizedString("activity_txt224", comment: " 포인트 1분 이후 10초에")) \(ep)\(NSLocalizedString("activity_txt213", comment: "포인트 차감됩니다."))"
        }
        myAddChildViewController(superView: self.view, childViewController: watingTimerVc)
    }
    func requestPaymentStartPoint() {
        var param = [String:Any]()
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_sex"] = ShareData.ins.mySex.rawValue
        param["to_user_id"] = toUserId!
        param["out_point"] = baseStartPoint
        param["room_key"] = roomKey!
        
        ApiManager.ins.requestCamCallPaymentStartPoint(param: param) { response in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                self.nowPoint -= self.baseStartPoint
                print("==== 1차 차감완료 \(response)");
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
//        영상채팅 최초 연결 시
//        1분간 1200포인트 차감
//        이후 10초당 200포인트 차감
//
//        음성채팅 최초 연결 시
//        1분간 600포인트 차감
//        10초당 100포인트 차감
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_sex"] = ShareData.ins.mySex.rawValue
        param["to_user_id"] = toUserId!
        var checkPoint:Int = Int(second - 60) //처음 1분은 빼고 계산
        if checkPoint < 0 {
            checkPoint = 0
        }
        checkPoint = Int(checkPoint/10)
        param["out_point_time"] = checkPoint*baseLivePoint
        param["room_key"] = roomKey!
        ApiManager.ins.requestCamCallPaymentEndPoint(param: param) { response in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                print("==== 2차 차감완료 \(response)");
            }
            else {
                print("==== 오류: 2차차감 오류 \(response)");
            }
        } fail: { error in
            print("==== 오류: 2차차감 오류 \(error)");
//            self.showErrorToast(error)
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
    ///MARK:: pangestueHandler
    @IBAction func pangestureHandeler(_ sender: UIPanGestureRecognizer) {
        
        guard let panView = sender.view, let value = panView.accessibilityValue, value == "S" else {
            return
        }
        let transition = sender.translation(in: panView)
        var x = panView.center.x + transition.x
        var y = panView.center.y + transition.y
        
        if sender.state == .changed {
            if x > (baseVideoView.bounds.width - panView.bounds.width/2) {
                x = baseVideoView.bounds.width - panView.bounds.width/2
            }
            else if x < panView.bounds.width/2 {
                x = panView.bounds.width/2
            }
            
            if y > (baseVideoView.bounds.maxY - panView.bounds.height/2 - baseVideoView.safeAreaInsets.bottom) {
                y = baseVideoView.bounds.maxY - panView.bounds.height/2  - baseVideoView.safeAreaInsets.bottom
            }
            else if y < panView.bounds.height/2 + baseVideoView.safeAreaInsets.top {
                y = panView.bounds.height/2 + baseVideoView.safeAreaInsets.top
            }
            
            panView.center = CGPoint(x: x, y: y)
            sender.setTranslation(CGPoint.zero, in: panView)
        }
        else if sender.state == .ended {
            let tPoint = baseVideoView.convert(panView.center, to: nil)
            let sPoint = CGPoint(x: baseVideoView.bounds.size.width/2, y: baseVideoView.bounds.size.height/2)
            
            var posX: CGFloat = 0
            var posY: CGFloat = 0
            let maxX = baseVideoView.bounds.maxX
            let maxY = baseVideoView.bounds.maxY
            
            let safetyInset = baseVideoView.safeAreaInsets
            if tPoint.x > sPoint.x && tPoint.y < sPoint.y { //1사분구
                if (maxX - tPoint.x) < (tPoint.y - safetyInset.top) {
                    posX = maxX - panView.bounds.width/2
                    posY = tPoint.y
                }
                else {
                    posX = tPoint.x
                    posY += safetyInset.top + panView.bounds.height/2
                }
            }
            else if tPoint.x < sPoint.x && tPoint.y < sPoint.y { //2사분구
                if tPoint.x < (tPoint.y - safetyInset.top) {
                    posX = panView.bounds.width/2
                    posY = tPoint.y
                }
                else {
                    posX = tPoint.x
                    posY += safetyInset.top + panView.bounds.height/2
                }
            }
            else if tPoint.x < sPoint.x && tPoint.y > sPoint.y { //3사분구
                if tPoint.x < ((maxY - safetyInset.bottom) - tPoint.y) {
                    posX = panView.bounds.width/2
                    posY = tPoint.y
                }
                else {
                    posX = tPoint.x
                    posY += maxY - safetyInset.bottom - panView.bounds.height/2
                }
            }
            else if tPoint.x > sPoint.x && tPoint.y > sPoint.y { //4사분구
                if (maxX - tPoint.x) < ((maxY - safetyInset.bottom) - tPoint.y) {
                    posX = maxX - panView.bounds.width/2
                    posY = tPoint.y
                }
                else {
                    posX = tPoint.x
                    posY += maxY - safetyInset.bottom - panView.bounds.height/2
                }
            }
            self.sPoint = CGPoint(x: posX, y: posY)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
                panView.center = self.sPoint
            } completion: { finish in
                
            }
        }
    }
    
    func findNearestEdge(_ targetView:UIView) -> CGPoint {
        
        
        return CGPoint.zero
    }
    ///MARK:: tapgesturehandler
    @IBAction func tapGestureHandeler(_ sender: UITapGestureRecognizer) {
        guard let tapView = sender.view, let value = tapView.accessibilityValue, value == "S" else {
            return
        }
        
        if tapView == locaVideo {
            locaVideo.accessibilityValue = "L"
            mainVideo.accessibilityValue = "S"
            self.translateExpand(from: locaVideo, to: mainVideo)
        }
        else if tapView == mainVideo {
            locaVideo.accessibilityValue = "S"
            mainVideo.accessibilityValue = "L"
            self.translateExpand(from: mainVideo, to: locaVideo)
        }
        
    }
    
    func translateExpand(from targetView:UIView, to downSizeView:UIView) {
        
        targetView.removeConstraints()
        downSizeView.removeConstraints()
        
        targetView.topAnchor.constraint(equalTo: self.baseVideoView.topAnchor, constant: 0).isActive = true
        targetView.leadingAnchor.constraint(equalTo: self.baseVideoView.leadingAnchor, constant: 0).isActive = true
        targetView.bottomAnchor.constraint(equalTo: self.baseVideoView.bottomAnchor, constant: 0).isActive = true
        targetView.trailingAnchor.constraint(equalTo: self.baseVideoView.trailingAnchor, constant: 0).isActive = true
        
        if let subview = targetView.subviews.first {
            targetView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                     options: [],
                                                                     metrics: nil,
                                                                     views: ["view":subview]))
            
            targetView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                     options: [],
                                                                     metrics: nil,
                                                                     views: ["view":subview]))
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { finish in
            
            downSizeView.topAnchor.constraint(equalTo: self.baseVideoView.safeAreaLayoutGuide.topAnchor, constant: 56).isActive = true
            downSizeView.leadingAnchor.constraint(equalTo: self.baseVideoView.leadingAnchor, constant: 16).isActive = true
            downSizeView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            downSizeView.heightAnchor.constraint(equalToConstant: 150).isActive = true
            self.view.layoutIfNeeded()
            
            if let subview = downSizeView.subviews.first {
                downSizeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                         options: [],
                                                                         metrics: nil,
                                                                         views: ["view":subview]))
                
                downSizeView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                         options: [],
                                                                         metrics: nil,
                                                                         views: ["view":subview]))
            }
            self.baseVideoView.bringSubviewToFront(downSizeView)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnBack {
            CAlertViewController.show(type: .alert, title: nil, message: NSLocalizedString("activity_txt188", comment: "영상 통화를 종료합니다."), actions: [.cancel, .ok]) { (vcs, selItem, action) in
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
        } else if sender == btnSpeaker {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                webRtcClient.speakerOn()
                btnSpeaker.tintColor = colorGreen
                btnSpeaker.backgroundColor = UIColor.white
            }
            else {
                self.webRtcClient.speakerOff()
                btnSpeaker.tintColor = UIColor.black
                btnSpeaker.backgroundColor = colorGreen
            }
        } else if sender == btnCamera {
            //카메라
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                if let localRender = locaVideo.subviews.first as? RTCEAGLVideoView {
                    webRtcClient.swapCameraToBack(localRender)
                }
                else if let localRender = locaVideo.subviews.first as? RTCEAGLVideoView{
                    webRtcClient.swapCameraToBack(localRender)
                }
                
                btnCamera.tintColor = colorGreen
                btnCamera.backgroundColor = UIColor.white
            }
            else {
                if let localRender = locaVideo.subviews.first as? RTCEAGLVideoView {
                    webRtcClient.swapCameraToFront(localRender)
                }
                else if let localRender = locaVideo.subviews.first as? RTCEAGLVideoView{
                    webRtcClient.swapCameraToFront(localRender)
                }
                btnCamera.tintColor = UIColor.black
                btnCamera.backgroundColor = colorGreen
            }
            
        } else if sender == btnMsg {
            let alert = CAlertViewController.init(type: .alert,title: nil, message: nil, actions: [.cancel, .ok]) { (vcs, selItem, action) in
                vcs.dismiss(animated: false, completion: nil)
                if action == 1 {
                    guard let textView = vcs.arrTextView.first, let text = textView.text, text.isEmpty == false else {
                        return
                    }
                    self.sendMessage(text)
                }
            }
        
            alert.addTextView(NSLocalizedString("input_content", comment: "입력해주세요."))
            alert.reloadUI()
            self.present(alert, animated: false) {
                guard let textView = alert.arrTextView.first else { return }
                textView.becomeFirstResponder()
            }
            
        } else if sender == btnGift {
            print("선물")
            
            let strMyPoint = "\(nowPoint)".addComma()+"P"
            let tmpStr = "\(NSLocalizedString("activity_txt183", comment: "보유 :")) \(strMyPoint)"
            let title = "\(toUserName!)\(NSLocalizedString("activity_txt180", comment: "님에게 선물하기"))\n\(tmpStr)"
            let paragraphic = NSMutableParagraphStyle.init()
            paragraphic.lineSpacing = 5
            let attr = NSMutableAttributedString.init(string: title)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: NSMakeRange(0, title.length))
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .medium), range: (title as NSString).range(of: tmpStr))
            attr.addAttribute(.foregroundColor, value: RGB(230, 100, 100), range: (title as NSString).range(of: tmpStr))
            attr.addAttribute(.paragraphStyle, value: paragraphic, range: NSMakeRange(0, title.length))
            let des = (NSLocalizedString("chat_star_point", comment: "별(P)"))
            let data:[String] = ["100\(des)", "500\(des)", "1,000\(des)", "3,000\(des)", "5,000\(des)", "10,000\(des)"]
            let vc = PopupCollectionListViewController.initWithType(.gift, attr, data, nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                var giftPoint:Int = 0
                if index == 0 {
                    giftPoint = 100
                }
                else if index == 1 {
                    giftPoint = 500
                }
                else if index == 2 {
                    giftPoint = 1000
                }
                else if index == 3 {
                    giftPoint = 3000
                }
                else if index == 4 {
                    giftPoint = 5000
                }
                else if index == 5 {
                    giftPoint = 10000
                }
                
                if giftPoint > self.nowPoint  || self.nowPoint <= 200 {
                    self.showToast(NSLocalizedString("activity_txt182", comment: "최소 200포인트가 있어야 선물 가능합니다"))
                    return
                }
                else {
                    var param:[String:Any] = [:]
                    let gift_point_str = "\(giftPoint)"
                    param["to_user_id"] =  self.toUserId!
                    param["user_id"] = ShareData.ins.myId
                    param["seq"] = "NO"
                    param["gift_point_str"] = gift_point_str
                    param["gift_comment_write_str"] = "\(giftPoint)"
                    
                    ApiManager.ins.requestSendGiftPointCam(param:param) { (res) in
                        let isSuccess = res["isSuccess"].stringValue
                        if isSuccess == "01" {
                            self.nowPoint -= giftPoint
                            let msg = "🎁 \(self.toUserName!)\(NSLocalizedString("activity_txt194", comment: "님에게 선물")) \(gift_point_str.addComma()) \(NSLocalizedString("activity_txt249", comment: "별(P)를 선물 했습니다."))"
                            self.sendMessage(msg)
                        }
                        else {
                            self.showErrorToast(res)
                        }
                    } fail: { (error) in
                        self.showErrorToast(error)
                    }
                }
            }
            self.presentPanModal(vc)
        } else if sender == btnMyFriend {
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

        } else if sender == btnLike {
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
        } else if sender == btnMicroPhone {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.webRtcClient.unmuteAudio()
            }
            else {
                self.webRtcClient.muteAudio()
            }
        }
        
    }
    func sendMessage(_ msg:String) {
        print("\(msg)")
        appendMessage("나야: \(msg)")
        self.signalClient.sendMessage(to: toUserId, message: msg, roomKey: roomKey)
    }
    func appendMessage(_ msg:String) {
        self.originListData.append(msg)
        listData.removeAll()
        listData = self.originListData.reversed()
        self.tblView.isHidden = false
        self.tblView.reloadData()
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

extension CamCallViewController: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didReceiveLocalVideoTrack videoTrack: RTCVideoTrack) {
        print("didReceiveLocalVideoTrack")
    }
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("== webrtc didDiscoverLocalCandidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        print("== webrtc didChangeConnectionState")
        DispatchQueue.main.async {
            var textColor = UIColor.label
            switch state {
            case .connected, .completed:
                textColor = .green
                AppDelegate.ins.window?.makeToast(NSLocalizedString("activity_txt315", comment: "수락"))
                break
            case .disconnected:
                textColor = .orange
//                AppDelegate.ins.window?.makeToast("연결 끊김")
                print("연결 끊김")
                DispatchQueue.main.async {
                    self.stopTimer()
                }
                break
            case .failed:
                textColor = .red
//                AppDelegate.ins.window?.makeToast("실패")
                print("실패")
                break
            case .new, .checking, .count:
                textColor = .purple
            default:
                break
            }
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
        self.appendMessage(msg)
    }
}
///MARK:: tableview datasouce, deletage
extension CamCallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier) as? MessageCell else {
            return UITableViewCell.init(style: .default, reuseIdentifier: MessageCell.identifier)
        }
        
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.ivProfile.layer.cornerRadius = cell.ivProfile.bounds.height/2
        
        if let msg = listData[indexPath.row] as? String, let comp = msg.components(separatedBy: ":") as? [String] {
            if comp.first == "나야" {
                cell.ivProfile.isHidden = true
                if let str = comp.last?.trimmingCharacters(in: .whitespacesAndNewlines), let jonStr = str.components(separatedBy: CharacterSet.newlines).joined(separator: " ") as? String {
                    cell.lbMsg.text = jonStr
                }
            }
            else {
                cell.ivProfile.isHidden = false
                cell.ivProfile.image = ShareData.ins.mySex.transGender().avatar()
                if let user_img = info?["user_img"].stringValue, let url = Utility.thumbnailUrl(toUserId, user_img) {
                    cell.ivProfile.setImageCache(url)
                }
                if let str = comp.last?.trimmingCharacters(in: .whitespacesAndNewlines), let jonStr = str.components(separatedBy: CharacterSet.newlines).joined(separator: " ") as? String {
                    cell.lbMsg.text = jonStr
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblView.deselectRow(at: indexPath, animated: true)
    }
}
