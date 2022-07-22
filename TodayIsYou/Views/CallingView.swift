//
//  CallingView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/25.
//

import UIKit
import SwiftyJSON
import AVFoundation

class CallingView: UIView {
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var btnBell: PulseButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var btnReject: CButton!
    @IBOutlet weak var btnAccept: CButton!
    @IBOutlet weak var svBtn: UIStackView!
    
    var player = AVAudioPlayer.init()
    
    var completion:((_ data: CallingModel, _ actionIndex:Int)->Void)?
    var model: CallingModel!
    var shakTimer:Timer!
    var count = 0
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    func configurationData(_ type:PushType, _ model:CallingModel, _ completion:((_ data: CallingModel, _ actionIndex:Int)->Void)?) {

        self.model = model
        self.completion = completion
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_:)))
        self.addGestureRecognizer(tap)
        
        btnBell.isAnimated = true
        if type == .rdCam {
            svBtn.isHidden = true
        }
        
        if let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as? String {
            if notiYn == "A" || notiYn == "S" {
                appDelegate.audioPlayer.play()
            }
        }
        
        if let notiYn = ShareData.ins.dfsGet(DfsKey.notiYn) as? String {
            if notiYn == "A" || notiYn == "V" {
                self.stopShakTimer()
                self.shakTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (time) in
                    self.count += 1
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    if self.count >= 30 {
                        time.invalidate()
                        time.fire()
                    }
                }
            }
        }
        
        svBtn.isHidden = false
        
        if type == .cam {
            lbTitle.text = "\(model.from_user_name)(\(model.from_user_gender), \(model.from_user_age)\(NSLocalizedString("activity_txt317", comment: ")이 영상채팅을 신청했습니다.!!"))"
            if "남" == ShareData.ins.mySex.rawValue {
                let p = ShareData.ins.dfsGet(DfsKey.phoneOutUserPoint) as! NSNumber
                lbSubTitle.text = "\(NSLocalizedString("activity_txt205", comment: "수락 시 10초당")) \(p.stringValue) \(NSLocalizedString("activity_txt213", comment: "포인트가 차감됩니다."))"
            }
            else {
                lbSubTitle.text = NSLocalizedString("activity_txt321", comment: "수락(음성채팅) 시 여성은 별이 적립됩니다.")
            }
        }
        else if type == .phone {
            lbTitle.text = "\(model.from_user_name)(\(model.from_user_gender), \(model.from_user_age)\(NSLocalizedString("activity_txt323", comment: ")이 음성채팅을 신청 했습니다!!"))"
            if "남" == ShareData.ins.mySex.rawValue {
                let p = ShareData.ins.dfsGet(DfsKey.phoneOutUserPoint) as! NSNumber
                lbSubTitle.text = "\(NSLocalizedString("activity_txt205", comment: "수락 시 10초당")) \(p.stringValue) \(NSLocalizedString("activity_txt213", comment: "포인트가 차감됩니다."))"
            }
            else {
                lbSubTitle.text = NSLocalizedString("activity_txt321_2", comment: "수락(음성채팅) 시 여성은 별이 적립됩니다.")
            }
        }
        else if type == .rdSend {    //랜덤 채팅 포그라운드 상태
            lbTitle.text = NSLocalizedString("activity_txt310", comment: "activity_txt310")
            lbSubTitle.text = NSLocalizedString("activity_txt311", comment: "영상채팅 신청이 도착했습니다!!")
            svBtn.isHidden = true
        }
     }
    @objc func tapGestureHandler(_ gesture: UIGestureRecognizer) {
        if gesture.view == self {
            completion?(self.model, 200)
        }
    }
    
    @IBAction func onClickedBtnactions(_ sender: UIButton) {
        if sender == btnReject {
            completion?(self.model, 100)
        }
        else if sender == btnAccept {
            completion?(self.model, 101)
        }
    }
    class func show(_ type:PushType, _ model: CallingModel, _ completion:((_ model: CallingModel, _ actionIndex:Int)->Void)?) {
        let window = appDelegate.window
        if let view = window?.viewWithTag(TagCallingView) {
            view.removeFromSuperview()
        }
        
        let callingview = Bundle.main.loadNibNamed("CallingView", owner: nil, options: nil)?.first as! CallingView
        
        window?.addSubview(callingview)
        callingview.tag = TagCallingView
        callingview.translatesAutoresizingMaskIntoConstraints = false
        callingview.topAnchor.constraint(equalTo: window!.topAnchor, constant: 0).isActive = true
        callingview.leadingAnchor.constraint(equalTo: window!.leadingAnchor, constant: 0).isActive = true
        callingview.trailingAnchor.constraint(equalTo: window!.trailingAnchor, constant: 0).isActive = true
        callingview.addShadow(offset: CGSize(width: 3, height: 3), color: RGBA(0, 0, 0, 0.3), raduius: 3, opacity: 0.3)
        let top = window!.safeAreaInsets.top + 16
        callingview.svContent.layoutMargins = UIEdgeInsets(top: top, left: 16, bottom: 16, right: 16)
        
        callingview.configurationData(type, model, completion)
    }
    func stopShakTimer() {
        if let timer = shakTimer {
            timer.invalidate()
            timer.fire()
        }
    }
    deinit {
        print("callingview deinit")
        self.stopShakTimer()
    }
}
