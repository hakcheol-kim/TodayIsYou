//
//  AdminNoticeViewController.swift
//  TodayIsYou
//
//  Created by minjib kim on 2021/10/13.
//

import UIKit

class AdminNoticeViewController: BaseViewController {
    @IBOutlet weak var btnFull: UIButton!
    @IBOutlet weak var btnIcon: CButton!
    @IBOutlet weak var lbDownCount: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lbSubMsg: UILabel!
    
    var adminTitle: String?
    var message: String?
    var completion:(()->Void)?
    static func instantiateFromStoryboard(_ completion:(() -> Void)?) ->AdminNoticeViewController {
        let vc = AdminNoticeViewController.instantiateFromStoryboard(.main)!
        vc.completion = completion
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbDownCount.text = adminTitle
        self.lbSubMsg.text = message
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
    }
    
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCancel {
            self.dismiss(animated: false, completion: nil)
            self.completion?()
        }
    }

}
