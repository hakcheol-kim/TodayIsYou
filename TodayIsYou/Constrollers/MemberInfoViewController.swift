//
//  MemberInfoViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/24.
//

import UIKit
import PanModal
import PhoneNumberKit

class MemberInfoViewController: BaseViewController {
    @IBOutlet weak var tfNickName: CTextField!
    @IBOutlet weak var tfPhoneNumber: CTextField!
    @IBOutlet weak var btnGender: CButton!
    @IBOutlet weak var btnAge: CButton!
    @IBOutlet weak var btnArea: CButton!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var btnVibrate: UIButton!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var safeView: UIView!
    @IBOutlet weak var btnOk: UIButton!
    
    @IBOutlet weak var lbHintNickname: UILabel!
    @IBOutlet weak var lbHintPhone: UILabel!
    @IBOutlet weak var lbHintInfo: UILabel!
    
    let phoneNumberKit = PhoneNumberKit()
    var user:[String:Any] = [:]
    let toolbar = CToolbar.init(barItems: [.keyboardDown])
    var selGender: String = "" {
        didSet {
            if let tfTitle = btnGender.viewWithTag(100) as? UITextField {
                tfTitle.text = selGender
            }
        }
    }
    var selAge: String = "" {
        didSet {
            if let tfTitle = btnAge.viewWithTag(100) as? UITextField {
                tfTitle.text = selAge
            }
        }
    }
    var selArea: String = "" {
        didSet {
            if let tfTitle = btnArea.viewWithTag(100) as? UITextField {
                tfTitle.text = selArea
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "회원가입", #selector(actionNaviBack))
        tfNickName.inputAccessoryView = toolbar
        tfPhoneNumber.inputAccessoryView = toolbar
        toolbar.addTarget(self, selctor: #selector(actionKeybardDown))
        self.addTapGestureKeyBoardDown()
        safeView.isHidden = !Utility.isEdgePhone()
        
        btnSound.isSelected = true
        btnVibrate.isSelected = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    @IBAction func textFieldEdtingChanged(_ sender: UITextField) {
        if sender == tfPhoneNumber {
            guard let text = sender.text, text.isEmpty == false else {
                return
            }
            do {
                let phoneNumber = try phoneNumberKit.parse(text, ignoreType: true)
                let newNum = self.phoneNumberKit.format(phoneNumber, toType: .national)
                self.tfPhoneNumber.text = newNum
            } catch {
                self.tfPhoneNumber.text = text
            }
        }

    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if sender == btnGender {
            let vc = PopupListViewController.initWithType(.normal, "성별을 선택해주세요.", [Gender.femail.rawValue, Gender.mail.rawValue], nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? String else {
                    return
                }
                self.selGender = item
            }
            presentPanModal(vc)
        }
        else if sender == btnAge {
            let vc = PopupListViewController.initWithType(.normal, "연령 선택해주세요.", ageRange, nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? String else {
                    return
                }
                self.selAge = item
            }
            presentPanModal(vc)
        }
        else if sender == btnArea {
            let vc = PopupListViewController.initWithType(.normal, "지역 선택해주세요.", areaRange, nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? String else {
                    return
                }
                self.selArea = item
            }
            presentPanModal(vc)
        }
        else if sender == btnSound {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                btnMute.isSelected = false
            }
        }
        else if sender == btnVibrate {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                btnMute.isSelected = false
            }
        }
        else if sender == btnMute {
            sender.isSelected = !sender.isSelected
            if sender.isSelected == true {
                btnSound.isSelected = false
                btnVibrate.isSelected = false
            }
        }
        else if sender == btnOk {
            var isOK = true
            lbHintNickname.isHidden = true
            if let nickname = tfNickName.text, nickname.isEmpty == true {
                lbHintNickname.isHidden = false
                lbHintNickname.text = "닉네임을 입력해주세요."
                isOK = false
            }
            else if tfNickName.text!.length  < 3  {
                lbHintNickname.isHidden = false
                lbHintNickname.text = "3글자 이상 닉넴임을 입력해주세요."
                isOK = false
            }
            tfNickName.text = ProfanityFilter.ins.cleanUp(tfNickName.text!)

            lbHintPhone.isHidden = true
            if let phone = tfPhoneNumber.text, phone.isEmpty == false {
                if phone.validateKorPhoneNumber() == false {
                    lbHintPhone.isHidden = false
                    lbHintPhone.text = "폰번호 형식이 아닙니다."
                    isOK = false
                }
            }
            lbHintInfo.isHidden = true
            guard let tfGender = btnGender.viewWithTag(100) as? UITextField, let gender = tfGender.text, gender.isEmpty == false else {
                lbHintInfo.isHidden = false
                return
            }
            guard let tfAge = btnAge.viewWithTag(100) as? UITextField, let age = tfAge.text, age.isEmpty == false else {
                lbHintInfo.isHidden = false
                return
            }
            guard let tfArea = btnArea.viewWithTag(100) as? UITextField, let area = tfArea.text, area.isEmpty == false else {
                lbHintInfo.isHidden = false
                return
            }
            
            if isOK == false {
                return
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
            
            user["app_type"] = appType
            user["save_type"] = "G"
            user["version_code"] = Bundle.main.appVersion
            user["locale"] = Locale.current.languageCode
            user["user_name"] = tfNickName.text!
            
            user["user_sex"] = gender
            user["user_age"] = age
            user["user_area"] = area
            user["noti_yn"] = notiYn
            user["user_phone"] = tfPhoneNumber.text!
            
            ApiManager.ins.requestMemberRegist(param: user) { (response) in
                let isSuccess = response["isSuccess"].stringValue
                if isSuccess == "01" {
                    let alert = CAlertViewController.init(type: .alert, title: nil, message: "회원가입이 완료되었습니다.", actions: [.ok]) { (vcs, selitem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                        ShareData.ins.dfsSetValue(self.user["user_id"], forKey: DfsKey.userId)
                        AppDelegate.ins.callMainViewCtrl()
                    }
                    self.present(alert, animated: true, completion: nil)
                }
                else if isSuccess == "02" {
                    CAlertViewController.show(type: .alert, title: nil, message: "닉네임이 중복 되었습니다.", actions: [.ok]) { (vcs, selItem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    CAlertViewController.show(type: .alert, title: nil, message: "중복가입 유저입니다.", actions: [.ok]) { (vcs, selItem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                    }
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
    }
}

