//
//  ConfigurationViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON

class ConfigurationViewController: BaseViewController {
    @IBOutlet weak var btnNewUserAlarm: UIButton!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var btnVibrate: UIButton!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    
    var user: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "설정", #selector(actionNaviBack))
        
        self.reqeustGetUserInfo()
    }
    
    func reqeustGetUserInfo() {
        let param = ["user_id": ShareData.ins.userId]
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            let isSuccess = response["isSuccess"]
            if isSuccess == "01" {
                self.user = response
                ShareData.ins.setUserInfo(self.user)
                self.configurationData()
            }
            else {
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    func configurationData() {
        let connectPush = user["connect_push"].stringValue
        let notiYn = user["noti_yn"].stringValue
        
        btnNewUserAlarm.isSelected = false
        if connectPush == "Y" {
            btnNewUserAlarm.isSelected = true
        }
        
        btnSound.isSelected = false
        btnVibrate.isSelected = false
        btnMute.isSelected = false
        
        if notiYn == "A" {
            btnSound.isSelected = true
            btnVibrate.isSelected = true
        }
        else if notiYn == "S" {
            btnSound.isSelected = true
        }
        else if notiYn == "V" {
            btnVibrate.isSelected = true
        }
        else {
            btnMute.isSelected = true
        }
        
        let version = Bundle.main.appVersion
        btnUpdate.setTitle("현재 버전(\(version))", for: .normal)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
        if sender == btnNewUserAlarm {
            sender.isSelected = !sender.isSelected
            self.requestUpdateSetting()
        }
        else if sender == btnSound {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                btnMute.isSelected = false
            }
            else if btnSound.isSelected == false && btnVibrate.isSelected == false {
                btnMute.isSelected = true
            }
            self.requestUpdateSetting()
        }
        else if sender == btnVibrate {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                btnMute.isSelected = false
            }
            else if btnSound.isSelected == false && btnVibrate.isSelected == false {
                btnMute.isSelected = true
            }
            self.requestUpdateSetting()
        }
        else if sender == btnMute {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                btnSound.isSelected = false
                btnVibrate.isSelected = false
            }
            self.requestUpdateSetting()
        }
        else if sender == btnUpdate {
            //TODO:: goto appstore url
        }
        else if sender == btnExit {
            let msg = "15일 후 재가입 가능합니다.\n탈퇴시 별,포인트는 소멸 되며 환불되지 않습니다."
            CAlertViewController.show(type: .alert, title:"회원 탈퇴", message: msg, actions: [.cancel, .ok]) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                if index == 1 {
                    self.resputUserOut()
                }
            }
        }
    }
    func resputUserOut() {
        let param = ["user_id": ShareData.ins.userId]
        ApiManager.ins.requestUserOut(param:param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                
            }
            else {
                self.showErrorToast(res)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }

    }
    func requestUpdateSetting() {
        var connectPush = "N"
        if btnNewUserAlarm.isSelected {
            connectPush = "Y"
        }
        
        var notiYn = "N"
        if btnSound.isSelected && btnVibrate.isSelected {
            notiYn = "A"
        }
        else if btnSound.isSelected {
            notiYn = "S"
        }
        else if btnVibrate.isSelected {
            notiYn = "V"
        }
        
        var param:[String:Any] = [:]
        param["user_id"] = ShareData.ins.userId
        param["recommend"] = "Y"
        param["noti_yn"] = notiYn
        param["connect_push"] = connectPush
        print("param: \(param)")
        ApiManager.ins.requestUpdateUserSetting(param: param) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                self.showToast("설정변경 완료되었습니다.")
            }
            else {
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
}
