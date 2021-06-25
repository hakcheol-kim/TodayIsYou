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
    @IBOutlet weak var btnSound: CButton!
    @IBOutlet weak var btnVibrate: CButton!
    @IBOutlet weak var btnMute: CButton!
    @IBOutlet weak var safeView: UIView!
    @IBOutlet weak var btnOk: CButton!
    @IBOutlet weak var btnOff: CButton!
    @IBOutlet weak var svPhoneNumber: UIStackView!
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
    var notiYn = "A"
    var timer:Timer?
    var selGender: String = ""
    var selAge: String = ""
    var selArea: String = ""
    
    var isCheckedAuth = false
    var joinType:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, NSLocalizedString("join_activity66", comment: "회원가입"), #selector(actionNaviBack))
        tfNickName.inputAccessoryView = toolbar
        tfPhoneNumber.inputAccessoryView = toolbar
        tfPartnerCode.inputAccessoryView = toolbar
        tfAuthCode.inputAccessoryView = toolbar
        
        toolbar.addTarget(self, selctor: #selector(actionKeybardDown))
        self.addTapGestureKeyBoardDown()
        safeView.isHidden = !Utility.isEdgePhone()
        
        btnSound.isSelected = true
        btnVibrate.isSelected = true
        
        lbHintPhone.text = ""
        lbHintAuthCode.text = ""
        lbHintNickname.text = ""
        lbHintInfo.text = ""
        
        btnSound.titleLabel?.numberOfLines = 0
        btnVibrate.titleLabel?.numberOfLines = 0
        btnMute.titleLabel?.numberOfLines = 0
        btnOff.titleLabel?.numberOfLines = 0
        
        let text = NSLocalizedString("layout_txt54", comment: "인증확인")
        let attrN = NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
        let attrS = NSAttributedString(string: text, attributes: [.foregroundColor: RGB(125, 125, 125)])
        btnAuthComfirm.setAttributedTitle(attrN, for: .normal)
        btnAuthComfirm.setAttributedTitle(attrS, for: .disabled)
        
        
        self.joinType = user["joinType"] as! String
        
        svPhoneNumber.isHidden = true
        svAuthCode.isHidden = true
        if joinType == "phone" {
            svPhoneNumber.isHidden = false
            svAuthCode.isHidden = false
        }
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
            let vc = PopupListViewController.initWithType(.normal, NSLocalizedString("join_activity07", comment: "성별을 선택해주세요."), ["root_display_txt21".localized, "root_display_txt20".localized], nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? String else {
                    return
                }
                if item == "Male" || item == "남" {
                    self.selGender = "남"
                }
                else {
                    self.selGender = "여"
                }
                if let tfTitle = self.btnGender.viewWithTag(100) as? CTextField {
                    tfTitle.text = item
                }
            }
            presentPanModal(vc)
        }
        else if sender == btnAge {
            var ages = [String]()
            for i in 2..<9 {
                let key = "age_\(i)"
                ages.append(NSLocalizedString(key, comment: ""))
            }
            
            let vc = PopupListViewController.initWithType(.normal, NSLocalizedString("activity_txt471", comment: "나이를 선택해주세요."), ages, nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? String else {
                    return
                }
                self.selAge = Age.severKey(item)
                if let tfTitle = self.btnAge.viewWithTag(100) as? CTextField {
                    tfTitle.text = item
                }
            }
            presentPanModal(vc)
        }
        else if sender == btnArea {
//            guard let area = ShareData.ins.getArea() else {
//                return
//            }
            var areas = [String]()
            for i in 0..<17 {
                let key = "area_\(i)"
                areas.append(key.localized)
            }
            let vc = PopupListViewController.initWithType(.normal, NSLocalizedString("join_activity09", comment: "지역 선택해주세요."), areas, nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let item = item as? String else {
                    return
                }
                self.selArea = Area.severKey(item)
                if let tfTitle = self.btnArea.viewWithTag(100) as? UITextField {
                    tfTitle.text = item
                }
            }
            presentPanModal(vc)
        }
        else if sender == btnPhoneAuth {
            lbHintPhone.text = ""
            guard let text = tfPhoneNumber.text, text.isEmpty == false else {
                lbHintPhone.text = NSLocalizedString("login_erro_msg", comment: "전화번호를 입력해주세요.")
                return
            }
            guard text.validateKorPhoneNumber() == true else {
                lbHintPhone.text = NSLocalizedString("login_code_erro1", comment: "전화번호 형식이 아닙니다.")
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
                lbHintAuthCode.text = NSLocalizedString("join_activity01", comment: "인증번호를 입력해주세요.")
                return
            }
            if code != authCode {
                lbHintAuthCode.text = NSLocalizedString("login_code_error", comment: "인증번호가 일치하지 않습니다.")
                return
            }
            
            appDelegate.startIndicator()
            self.stopTimer()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.isCheckedAuth = true
                self.tfAuthCode.isUserInteractionEnabled = false
                self.btnAuthComfirm.isEnabled = false
                appDelegate.stopIndicator()
            }
        }
        else if sender == btnSound {
            sender.isSelected = !sender.isSelected
            btnMute.isSelected = false
            btnOff.isSelected = false
            
            if btnSound.isSelected && btnVibrate.isSelected{
                notiYn = "A"
            }
            else if btnSound.isSelected == false && btnVibrate.isSelected == false {
                btnOff.isSelected = true
                notiYn = "N"
            }
            else if btnSound.isSelected == true {
                notiYn = "S"
            }
            else {
                notiYn = "V"
            }
        }
        else if sender == btnVibrate {
            sender.isSelected = !sender.isSelected
            
            btnMute.isSelected = false
            btnOff.isSelected = false
            
            if btnSound.isSelected && btnVibrate.isSelected{
                notiYn = "A"
            }
            else if btnSound.isSelected == false && btnVibrate.isSelected == false {
                btnOff.isSelected = true
                notiYn = "N"
            }
            else if btnVibrate.isSelected == true {
                notiYn = "V"
            }
            else {
                notiYn = "S"
            }
        }
        else if sender == btnMute {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                btnSound.isSelected = false
                btnVibrate.isSelected = false
                btnOff.isSelected = false
                notiYn = "M"
            }
            else {
                btnSound.isSelected = true
                btnVibrate.isSelected = true
                btnOff.isSelected = false
                notiYn = "A"
            }
        }
        else if sender == btnOff {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                btnSound.isSelected = false
                btnVibrate.isSelected = false
                btnMute.isSelected = false
                notiYn = "N"
            }
            else {
                btnSound.isSelected = true
                btnVibrate.isSelected = true
                btnMute.isSelected = false
                notiYn = "A"
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
            var planTextUserId = ""
            if joinType == "phone" {
                lbHintPhone.text = ""
                lbHintAuthCode.text = ""
                
                guard let phone = tfPhoneNumber.text, phone.isEmpty == false else {
                    lbHintPhone.text = NSLocalizedString("login_erro_msg", comment: "전화번호를 입력해주세요.")
                    return
                }
                guard phone.validateKorPhoneNumber() == true else {
                    lbHintPhone.text = NSLocalizedString("login_code_erro1", comment: "전화번호 형식이 아닙니다.")
                    return
                }
                
                if isCheckedAuth == false {
                    lbHintAuthCode.text = NSLocalizedString("join_auth_code_comfirm", comment: "전화번호 인증번호 확인을 해주세요.")
                    return
                }
                planTextUserId = phone
                user["user_id"] = Utility.createUserId(planTextUserId)
                user["user_phone"] = tfPhoneNumber.text!
            }
            else {
                planTextUserId = user["userId"] as! String
                user["user_id"] = Utility.createUserId(planTextUserId)
            }
            
            lbHintNickname.text = ""
            lbHintInfo.text = ""
            lbHintNickname.isHidden = true
            guard let nickname = tfNickName.text, nickname.isEmpty == false else {
                lbHintNickname.text = NSLocalizedString("join_activity06", comment: "닉네임을 입력해주세요.")
                lbHintNickname.isHidden = false
                return
            }
            
            guard nickname.length  > 2 else {
                lbHintNickname.text = NSLocalizedString("join_nickname_check", comment: "3글자 이상 닉넴임을 입력해주세요.")
                lbHintNickname.isHidden = false
                return
            }
            let profanNickname = ProfanityFilter.ins.cleanUp(nickname)
            tfNickName.text = profanNickname
            
            guard let tfGender = btnGender.viewWithTag(100) as? UITextField, let gender = tfGender.text, gender.isEmpty == false else {
                lbHintInfo.text = NSLocalizedString("join_activity07", comment: "성별을 선택해주세요.")
                return
            }
            guard let tfAge = btnAge.viewWithTag(100) as? UITextField, let age = tfAge.text, age.isEmpty == false else {
                lbHintInfo.text = NSLocalizedString("activity_txt471", comment: "나이를 선택해주세요.")
                return
            }
            guard let tfArea = btnArea.viewWithTag(100) as? UITextField, let area = tfArea.text, area.isEmpty == false else {
                lbHintInfo.text = NSLocalizedString("join_activity09", comment: "지역 선택해주세요.")
                return
            }
  
            user["app_type"] = appType
            user["save_type"] = "G"
            user["version_code"] = Bundle.main.appVersion
            user["locale"] = Locale.current.languageCode
            user["user_name"] = profanNickname
            user["user_sex"] = selGender
            user["user_age"] = selAge
            user["user_area"] = selArea
            user["noti_yn"] = notiYn
            user["forgn_lang"] = ShareData.ins.languageCode.uppercased()
            
            let userId = user["user_id"] as! String
            
            if let referalParam = ShareData.ins.dfsGet(DfsKey.referalParam) as? [String:Any], referalParam.isEmpty == false {
//                http://dbdbdeep.com/site19/gate/today/join_result.php?dbdbdeep_userid=&dbdbdeep_tel=01031244920&referrer=TEST_S00259878ZC05487261&mb=Y
                var param = [String:Any]()
                param = referalParam
                param["dbdbdeep_userid"] = userId
                param["dbdbdeep_tel"] = ""
                param["mb"] = "Y"
                
                ApiManager.ins.requestReferal(param: param) { res in
                    print("refreal request success")
                    
                } fail: { error in
                    print("refreal request error")
                }
                
                ShareData.ins.dfsRemove(DfsKey.referalParam)
            }
            
            ApiManager.ins.requestMemberRegist(param: user) { (response) in
                let isSuccess = response["isSuccess"].stringValue
                if isSuccess == "01" {
                    let alert = CAlertViewController.init(type: .alert, title: nil, message: NSLocalizedString("join_completed", comment: "회원가입이 완료되었습니다."), actions: [.ok]) { (vcs, selitem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                        
                        let saveKeychainPlanTxt = "\(self.joinType)|\(planTextUserId)"
//                        let userIdentifier = CipherManager.aes128EncrpytToHex(saveKeychainPlanTxt)
                        KeychainItem.saveUserInKeychain(saveKeychainPlanTxt)
                     
                        ShareData.ins.dfsSet(userId, DfsKey.userId)
                        ShareData.ins.myId = userId
                        if gender == "남" {
                            ShareData.ins.mySex = .mail
                        }
                        else {
                            ShareData.ins.mySex = .femail
                        }
                        AdbrixEvent.addEventLog(.signup, self.user)
                        AdbrixEvent.addEventLog(.joinComplete, self.user)
                        appDelegate.callMainViewCtrl()
                        self.requestNotiYnSetting()
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
                    CAlertViewController.show(type: .alert, title: nil, message: NSLocalizedString("join_activity16", comment: "닉네임 중복!!"), actions: [.ok]) { (vcs, selItem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    CAlertViewController.show(type: .alert, title: nil, message: NSLocalizedString("join_activity17", comment: "중복가입유저!!"), actions: [.ok]) { (vcs, selItem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                    }
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
    }
    func requestNotiYnSetting() {
        
        
        var param:[String:Any] = [:]
        param["user_id"] = ShareData.ins.myId
        param["recommend"] = "Y"
        param["noti_yn"] = "A"
        param["connect_push"] = "Y"
        print("param: \(param)")
        ApiManager.ins.requestUpdateUserSetting(param: param) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                self.showToast(NSLocalizedString("activity_txt308", comment: "설정변경"))
                ShareData.ins.dfsSet("A", DfsKey.notiYn)
                ShareData.ins.dfsSet("Y", DfsKey.connectPush)
            }
            else {
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    func setDownTimer() {
        let endTimer = Date.timeIntervalSinceReferenceDate+(AUTH_TIMEOUT_MIN * 60)
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
