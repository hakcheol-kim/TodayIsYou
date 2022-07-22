//
//  CallWaitingTimerViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/28.
//

import UIKit

class CallWaitingTimerViewController: BaseViewController {
    @IBOutlet weak var btnFull: UIButton!
    @IBOutlet weak var btnIcon: CButton!
    @IBOutlet weak var lbDownCount: UILabel!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lbSubMsg: UILabel!
    
    var type:PushType = .cam
    var timer:Timer?
    var endTime:TimeInterval = 0
    var completion:(()->Void)?
    var message: String?
    static func instantiateFromStoryboard(_ completion:(() -> Void)?) ->CallWaitingTimerViewController {
        let vc = CallWaitingTimerViewController.instantiateFromStoryboard(.call)!
        vc.completion = completion
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startTimer()
        if type == .cam {
            btnIcon.setImage(UIImage(systemName: "video.slash.fill"), for: .normal)
        }
        else if type == .phone {
            btnIcon.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        }
        lbSubMsg.isHidden = true
        if let message = message {
            lbSubMsg.isHidden = false
            lbSubMsg.text = message
        }
        btnIcon.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    func startTimer() {
        self.stopTimer()
        let stTime = Date().timeIntervalSinceReferenceDate
        self.endTime = stTime+30;
        
        let diff:Int = Int(self.endTime - stTime)
        let min = Int(diff/60)
        let sec = Int(diff%60)
        self.lbDownCount.text = NSString.init(format: "%02ld:%02ld", min, sec) as String
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            let diff:Int = Int(self.endTime - Date().timeIntervalSinceReferenceDate)
            if diff < 0 {
                self.stopTimer()
                self.dismiss(animated: true, completion: nil)
                self.completion?()
            }
            else {
                let min = Int(diff/60)
                let sec = Int(diff%60)
                self.lbDownCount.text = NSString.init(format: "%02ld:%02ld", min, sec) as String
            }
        })
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            timer.fire()
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCancel {
            self.dismiss(animated: true, completion: nil)
            self.completion?()
        }
    }

}
