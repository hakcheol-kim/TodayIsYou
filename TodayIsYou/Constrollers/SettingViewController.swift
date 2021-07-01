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
        
        btnJoinTerm.titleLabel?.numberOfLines = 0
        btnPrivacyTerm.titleLabel?.numberOfLines = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestMyInfo()
        self.requestGetPoint()
    }
    
    override func requestMyInfo() {
        ApiManager.ins.requestUerInfo(param: ["app_type": appType, "user_id": ShareData.ins.myId]) { (response) in
            self.userInfo = response
            self.decorationUi()
            ShareData.ins.setUserInfo(response)
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    func decorationUi() {
        let userName = userInfo["user_name"].stringValue
        let user_age = userInfo["user_age"].stringValue
        let user_img = userInfo["user_img"].stringValue
        let user_id = userInfo["user_id"].stringValue
        let user_sex = userInfo["user_sex"].stringValue
        lbUserInfo.text = "\(userName), \(Gender.localizedString(user_sex)), \(Age.localizedString(user_age))"
        
        let ivProfile = btnProfile.viewWithTag(100) as! UIImageViewAligned
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        ivProfile.clipsToBounds = true

        if let url = Utility.thumbnailUrl(user_id, user_img) {
            ivProfile.setImageCache(url)
        }
        else {
            ivProfile.image = Gender.defaultImg(user_sex)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnProfile {
            let vc = ProfileManagerViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnNotice {
            let vc = NoticeListViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
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
                                self.showToast(NSLocalizedString("activity_txt132", comment: "출석 체크 포인트가 적립 되었습니다"))
                            }
                            self.requestMyHomePoint()
                        }
                        else if "Y2" == point_save {
                            if "남" == ShareData.ins.mySex.rawValue {
                                var point = "0"
                                if let p = ShareData.ins.dfsGet(DfsKey.dayLimitPoint) as? NSNumber {
                                    point = p.stringValue
                                }
                                let msg = "\(point.addComma()) " + NSLocalizedString("activity_txt516", comment: "")
                                self.showToast(msg)
                            }
                        }
                        else if "N" == point_save {
                            self.showToast(NSLocalizedString("activity_txt135", comment: "이미 출석 체크를 했습니다"))
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
                self.showToast(NSLocalizedString("activity_txt136", comment: "여성은 무료입니다."))
            }
        }
        else if sender == btnPhoto {
            let vc = PhotoManagerViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnPoint {
            let vc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnExchange {
            let vc = PointGateViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnContactUs {
            let vc = ContactusViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnReport {
             
            let alert = CAlertViewController.init(type: .alert, title: NSLocalizedString("activity_txt495", comment: "신고하기"), message: nil, actions: [.cancel, .ok]) { (vcs, selItem, index) in
                
                if (index == 1) {
                    guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                        self.showToast(NSLocalizedString("activity_txt500", comment: "신고 대상을 입력 하세요"))
                        return
                    }
                    guard let msg = vcs.arrTextView.last?.text, msg.isEmpty == false else {
                        self.showToast(NSLocalizedString("activity_txt501", comment: "신고 내용을 입력 하세요"))
                        return
                    }
                    let reportWriteStr = NSLocalizedString("activity_txt502", comment: "신고대상") + " \(text)" + NSLocalizedString("activity_txt503", comment: "- 설정에서 입력") + msg
                    
                        let param = ["user_name":"", "user_id":ShareData.ins.myId, "memo":reportWriteStr]
                        ApiManager.ins.requestReport(param: param) { (res) in
                            let isSuccess = res["isSuccess"].stringValue
                            if isSuccess == "01" {
                                self.showToast(NSLocalizedString("activity_txt246", comment: "신고 완료"))
                            }
                            else {
                                self.showErrorToast(res)
                            }
                        } failure: { (error) in
                            self.showErrorToast(error)
                        }

                    
                    vcs.dismiss(animated: true, completion: nil)
                }
                else {
                    vcs.dismiss(animated: true, completion: nil)
                }
            }
            
            alert.iconImg = UIImage(named: "warning")
            alert.addTextView(NSLocalizedString("activity_txt496", comment: "신고대상"), UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), 40)
            alert.addTextView(NSLocalizedString("activity_txt497", comment: "신고내용"), UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), 120)
            
            self.present(alert, animated: true, completion: nil)
        }
        else if sender == btnSetting {
            let vc = ConfigurationViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnJoinTerm {
            ApiManager.ins.requestServiceTerms(mode: "yk1") { (response) in
                let yk = response["yk"].stringValue
                if yk.isEmpty == false {
                    let vc = TermsViewController.init()
                    vc.vcTitle = NSLocalizedString("yk1", comment: "가입 약관")
                    vc.content = yk
                    appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
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
                    vc.vcTitle = NSLocalizedString("yk2", comment: "개인정보 취급방침");
                    vc.content = yk;
                    appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
        else if sender == btnCyber {
            appDelegate.openUrl(cyberUrl, completion: nil)
        }
    }
    
}
