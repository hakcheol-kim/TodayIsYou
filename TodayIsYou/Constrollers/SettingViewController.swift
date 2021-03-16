//
//  SettingViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
class SettingViewController: BaseViewController {
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var lbUserInfo: UILabel!
    
    @IBOutlet weak var btnNotice: CButton!
    @IBOutlet weak var btnAbsent: CButton!
    @IBOutlet weak var btnPhoto: CButton!
    @IBOutlet weak var btnPoint: CButton!
    @IBOutlet weak var btnExchange: CButton!
    @IBOutlet weak var btnContactUs: CButton!
    @IBOutlet weak var btnReport: CButton!
    @IBOutlet weak var btnSetting: CButton!
    @IBOutlet weak var btnJoinTerm: CButton!
    @IBOutlet weak var btnPrivacyTerm: CButton!
    @IBOutlet weak var btnCyber: CButton!
    
    var userInfo:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestMyInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func requestMyInfo() {
        ApiManager.ins.requestUerInfo(param: ["user_id":ShareData.instance.userId]) { (response) in
            self.userInfo = response
            self.decorationUi()
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    func decorationUi() {
        let userName = userInfo["user_name"].stringValue
        let userSex = userInfo["user_sex"].stringValue
        let userAge = userInfo["user_age"].stringValue
        lbUserInfo.text = "\(userName), \(userSex), \(userAge)"
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnProfile {
            let vc = storyboard?.instantiateViewController(identifier: "ProfileManagerViewController") as! ProfileManagerViewController
            vc.data = userInfo
            AppDelegate.instance.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnNotice {
            guard let vc = storyboard?.instantiateViewController(identifier: "NoticeListViewController") as? NoticeListViewController else { return }
            AppDelegate.instance.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnAbsent {

        }
        else if sender == btnPhoto {
            guard let vc = storyboard?.instantiateViewController(identifier: "PhotoManagerViewController") as? PhotoManagerViewController else { return }
            AppDelegate.instance.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnPoint {
            guard let vc = storyboard?.instantiateViewController(identifier: "PointChargeViewController") as? PointChargeViewController else { return }
            AppDelegate.instance.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnExchange {
            guard let vc = storyboard?.instantiateViewController(identifier: "PointGateViewController") as? PointGateViewController else { return }
            AppDelegate.instance.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnContactUs {
            
        }
        else if sender == btnReport {
            
        }
        else if sender == btnSetting {
            
        }
        else if sender == btnJoinTerm {
            
        }
        else if sender == btnPrivacyTerm {
            
        }
        else if sender == btnCyber {
            
        }
    }
    
}
