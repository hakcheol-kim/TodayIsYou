//
//  SettingViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestMyInfo()
        AppDelegate.ins.mainViewCtrl.updateNaviPoint()
    }
    
    override func requestMyInfo() {
        ApiManager.ins.requestUerInfo(param: ["user_id":ShareData.ins.myId]) { (response) in
            self.userInfo = response
            self.decorationUi()
            ShareData.ins.setUserInfo(response)
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    func decorationUi() {
        let userName = userInfo["user_name"].stringValue
        let userSex = userInfo["user_sex"].stringValue
        let userAge = userInfo["user_age"].stringValue
        let user_img = userInfo["user_img"].stringValue
        let user_id = userInfo["user_id"].stringValue
        let user_sex = userInfo["user_sex"].stringValue
        lbUserInfo.text = "\(userName), \(userSex), \(userAge)"
        
        let ivProfile = btnProfile.viewWithTag(100) as! UIImageViewAligned
        if let url = Utility.thumbnailUrl(user_id, user_img) {
            ivProfile.setImageCache(url)
            ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
            ivProfile.clipsToBounds = true
        }
        else {
            ivProfile.image = Gender.defaultImg(user_sex)
            ivProfile.layer.cornerRadius = 0
            ivProfile.clipsToBounds = true
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnProfile {
            let vc = ProfileManagerViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnNotice {
            let vc = NoticeListViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnAbsent {
            let user_sex = userInfo["user_sex"].stringValue
            if user_sex == "남" {
                let user_id = userInfo["user_id"].stringValue
//                let day_login_point = userInfo["day_login_point"].numberValue
                let now_date = Utility.getCurrentDate(format: "yyyy-MM-dd")
                let param:[String : Any] = ["user_id":user_id, "user_point_type":"day_login_point", "now_date":now_date]
                ApiManager.ins.requestLoginCheck(param: param) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    let point_save = res["point_save"].stringValue
                    
                    if isSuccess == "01" {
                        if "Y1" == point_save {
                            if "남" == ShareData.ins.mySex.rawValue {
                                self.showToast("출석 체크 포인트가 적립 되었습니다")
                            }
                            self.requestMyHomePoint()
                        }
                        else if "Y2" == point_save {
                            if "남" == ShareData.ins.mySex.rawValue {
                                var point = "0"
                                if let p = ShareData.ins.dfsGet(DfsKey.dayLimitPoint) as? NSNumber {
                                    point = p.stringValue
                                }
                                let msg = "보유한 포인트가 \(point.addComma()) 이하일때 적립 가능합니다"
                                self.showToast(msg)
                            }
                        }
                        else if "N" == point_save {
                            self.showToast("이미 출석 체크를 했습니다")
                        }
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } failure: { (error) in
                    self.showErrorToast(error)
                }
            }
            else {
                self.showToast("여성은 무료입니다.")
            }
        }
        else if sender == btnPhoto {
            let vc = PhotoManagerViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnPoint {
            let vc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnExchange {
            let vc = PointGateViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnContactUs {
            let vc = ContactusViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnReport {
            
        }
        else if sender == btnSetting {
            let vc = ConfigurationViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnJoinTerm {
            ApiManager.ins.requestServiceTerms(mode: "yk1") { (response) in
                let yk = response["yk"].stringValue
                if yk.isEmpty == false {
                    let vc = TermsViewController.init()
                    vc.vcTitle = "가입 약관";
                    vc.content = yk
                    AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
        else if sender == btnPrivacyTerm {
            ApiManager.ins.requestServiceTerms(mode: "yk2") { (response) in
                let yk = response["yk"].stringValue
                if yk.isEmpty == false {
                    let vc = TermsViewController.init()
                    vc.vcTitle = "개인정보 취급방침";
                    vc.content = yk;
                    AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
        else if sender == btnCyber {
            AppDelegate.ins.openUrl(cyberUrl, completion: nil)
        }
    }
    
}
