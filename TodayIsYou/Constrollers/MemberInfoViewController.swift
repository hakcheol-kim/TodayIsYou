//
//  MemberInfoViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/24.
//

import UIKit
import PanModal

class MemberInfoViewController: BaseViewController {
    
    @IBOutlet weak var tfNickName: CTextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var btnPhoneAuth: UIButton!
    @IBOutlet weak var linePhoneNumber: UIView!
    
    @IBOutlet weak var btnGender: CButton!
    @IBOutlet weak var btnAge: CButton!
    @IBOutlet weak var btnArea: CButton!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var btnVibrate: UIButton!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var safeView: UIView!
    @IBOutlet weak var btnOk: UIButton!
    
    @IBOutlet weak var svAuthCode: UIStackView!
    @IBOutlet weak var tfAuthCode: UITextField!
    @IBOutlet weak var btnAuthComfirm: UIButton!
    @IBOutlet weak var lineAuthCode: UIView!
    @IBOutlet weak var lbHintAuthCode: UILabel!
    
    @IBOutlet weak var lbHintNickname: UILabel!
    @IBOutlet weak var lbHintPhone: UILabel!
    @IBOutlet weak var lbHintInfo: UILabel!
    @IBOutlet weak var tfPartnerCode: CTextField!
    
    var user:[String:Any] = [:]
    let toolbar = CToolbar.init(barItems: [.keyboardDown])
    var authCode:String = ""
    
    let TIMEOUT_MIN:Double = 3
    var timer:Timer?
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
    
    var isCheckedAuth = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "회원가입", #selector(actionNaviBack))
        tfNickName.inputAccessoryView = toolbar
        tfPhoneNumber.inputAccessoryView = toolbar
        tfPartnerCode.inputAccessoryView = toolbar
        
        toolbar.addTarget(self, selctor: #selector(actionKeybardDown))
        self.addTapGestureKeyBoardDown()
        safeView.isHidden = !Utility.isEdgePhone()
        
        btnSound.isSelected = true
        btnVibrate.isSelected = true
        
        lbHintPhone.text = ""
        lbHintAuthCode.text = ""
        lbHintNickname.text = ""
        lbHintInfo.text = ""
        
        
        let text = "인증확인"
        let attrN = NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
        let attrS = NSAttributedString(string: text, attributes: [.foregroundColor: RGB(125, 125, 125)])
        btnAuthComfirm.setAttributedTitle(attrN, for: .normal)
        btnAuthComfirm.setAttributedTitle(attrS, for: .disabled)
        
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
            tfPhoneNumber.text = text
            btnPhoneAuth.isEnabled = true
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
            guard let ageRange = ShareData.ins.getAge() else {
                return
            }
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
            guard let area = ShareData.ins.getArea() else {
                return
            }
            let vc = PopupListViewController.initWithType(.normal, "지역 선택해주세요.", area, nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? String else {
                    return
                }
                self.selArea = item
            }
            presentPanModal(vc)
        }
        else if sender == btnPhoneAuth {
            lbHintPhone.text = ""
            guard let text = tfPhoneNumber.text, text.isEmpty == false else {
                lbHintPhone.text = "전화번호를 입력해주세요."
                return
            }
            guard text.validateKorPhoneNumber() == true else {
                lbHintPhone.text = "전화번호 형식이 아닙니다."
                return
            }
            
            self.authCode = Utility.randomSms5digit()
            if text == "01010041004" {  //테스트 폰번호
                self.authCode = "12345"
            }
            let param = ["receiver":text, "service_key":"tiy1031", "contents":"오늘은너야인증번호[\(self.authCode)]"];
            ApiManager.ins.requestSmsAuthCode(param: param) { (res) in
                let code = res["code"].stringValue
                if code == "000" {
                    self.setDownTimer()
                }
                else {
                    let msg = res["msg"].stringValue
                    self.showErrorToast(msg)
                }
            } fail: { (err) in
                self.showErrorToast(err)
            }
        }
        else if sender == btnAuthComfirm {
            lbHintAuthCode.text = ""
            guard let code = tfAuthCode.text, code.isEmpty == false else {
                lbHintAuthCode.text = "인증번호를 입력해주세요."
                return
            }
            if code != authCode {
                lbHintAuthCode.text = "인증번호가 일치하지 않습니다."
                return
            }
            
            AppDelegate.ins.startIndicator()
            self.stopTimer()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.isCheckedAuth = true
                self.tfAuthCode.isUserInteractionEnabled = false
                self.btnAuthComfirm.isEnabled = false
                AppDelegate.ins.stopIndicator()
            }
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
            
            lbHintPhone.text = ""
            lbHintAuthCode.text = ""
            lbHintNickname.text = ""
            lbHintInfo.text = ""
            
            guard let phone = tfPhoneNumber.text, phone.isEmpty == false else {
                lbHintPhone.text = "전화번호를 입력해주세요."
                return
            }
            guard phone.validateKorPhoneNumber() == true else {
                lbHintPhone.text = "전화번호 형식이 아닙니다."
                return
            }
            
            if isCheckedAuth == false {
                lbHintAuthCode.text = "전화번호 인증번호 확인을 해주세요."
                return
            }
            
            if let nickname = tfNickName.text, nickname.isEmpty == true {
                lbHintNickname.text = "닉네임을 입력해주세요."
            }
            else if tfNickName.text!.length  < 3  {
                lbHintNickname.text = "3글자 이상 닉넴임을 입력해주세요."
            }
            
            tfNickName.text = ProfanityFilter.ins.cleanUp(tfNickName.text!)

            guard let tfGender = btnGender.viewWithTag(100) as? UITextField, let gender = tfGender.text, gender.isEmpty == false else {
                lbHintInfo.text = "성별을 선택해주세요."
                return
            }
            guard let tfAge = btnAge.viewWithTag(100) as? UITextField, let age = tfAge.text, age.isEmpty == false else {
                lbHintInfo.text = "연령을 선택해주세요."
                return
            }
            guard let tfArea = btnArea.viewWithTag(100) as? UITextField, let area = tfArea.text, area.isEmpty == false else {
                lbHintInfo.text = "지역을 선택해주세요."
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
            
            let userId = phone.md5()
            user["user_id"] = userId
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
            
            let joinType = "phone"      //쇼셜로그인 혹시 붙일수 있어서 타입을 설정함
            let id = phone              //키체인에 저장할 정보
            ApiManager.ins.requestMemberRegist(param: user) { (response) in
                let isSuccess = response["isSuccess"].stringValue
                if isSuccess == "01" {
                    let alert = CAlertViewController.init(type: .alert, title: nil, message: "회원가입이 완료되었습니다.", actions: [.ok]) { (vcs, selitem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                        ShareData.ins.dfsSetValue(userId, forKey: DfsKey.userId)
                        ShareData.ins.myId = userId
                        if gender == "남" {
                            ShareData.ins.mySex = .mail
                        }
                        else {
                            ShareData.ins.mySex = .femail
                        }
                        let userInfo = "\(joinType)|\(id)"  //키체인에 저장
                        KeychainItem.saveUserInKeychain(userInfo)
                        AppDelegate.ins.callMainViewCtrl()
                    }
                    self.present(alert, animated: true, completion: nil)
                    
                    if let partnerCode = self.tfPartnerCode.text, partnerCode.isEmpty == false {
                        let param = ["user_id":userId, "partner_id":partnerCode]
                        ApiManager.ins.requestRegistPartnerCode(param: param) { (res) in
                            let code = res["code"].stringValue
                            if code == "000" {
                            }
                            else {
                                let msg = res["msg"].stringValue
                                self.showErrorToast(msg)
                            }
                        } fail: { (error) in
                            self.showErrorToast(error)
                        }
                    }
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
    
    func setDownTimer() {
        let endTimer = Date.timeIntervalSinceReferenceDate+(TIMEOUT_MIN * 60)
        let diff:Int = Int(endTimer - Date.timeIntervalSinceReferenceDate)
        let minute = diff/60
        let second = (diff%60)
        let time = String(format: "%02ld:%02ld", minute, second)
        
        btnPhoneAuth.setTitle(time, for: .normal)
        btnPhoneAuth.setTitleColor(UIColor.red, for: .normal)
        btnPhoneAuth.isUserInteractionEnabled = false
        tfPhoneNumber.isUserInteractionEnabled = false
        tfAuthCode.becomeFirstResponder()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            let diff:Int = Int(endTimer - Date.timeIntervalSinceReferenceDate)
            if diff < 0 {
                self?.timeOut()
            }
            else {
                let minute = diff/60
                let second = (diff%60)
                let time = String(format: "%02ld:%02ld", minute, second)
                self?.btnPhoneAuth.setTitle(time, for: .normal)
            }
        }
    }
    func timeOut() {
        self.isCheckedAuth = false
        btnPhoneAuth.isUserInteractionEnabled = true
        btnPhoneAuth.setTitle("문자인증", for: .normal)
        btnPhoneAuth.setTitleColor(UIColor.label, for: .normal)
        tfPhoneNumber.isUserInteractionEnabled = true
        
        stopTimer()
    }
    func stopTimer() {
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        timer.fire()
    }
}

extension MemberInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfPhoneNumber {
            linePhoneNumber.backgroundColor = RGB(230, 100, 100);
        }
        else if textField == tfAuthCode {
            lineAuthCode.backgroundColor = RGB(230, 100, 100);
        }
        else if textField == tfNickName {
            tfNickName.borderColor = RGB(230, 100, 100);
        }
        else if textField == tfPartnerCode {
            tfPartnerCode.borderColor = RGB(230, 100, 100);
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfPhoneNumber {
            linePhoneNumber.backgroundColor = RGB(216, 216, 216);
        }
        else if textField == tfAuthCode {
            lineAuthCode.backgroundColor = RGB(216, 216, 216);
        }
        else if textField == tfNickName {
            tfNickName.borderColor = RGB(216, 216, 216);
        }
        else if textField == tfPartnerCode {
            tfPartnerCode.borderColor = RGB(216, 216, 216);
        }
    }
}
