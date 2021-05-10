//
//  LoginViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/23.
//

import UIKit
class LoginViewController: BaseViewController {
    
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var lbHintPhone: UILabel!
    @IBOutlet weak var underLinePhone: UIView!
    
    @IBOutlet weak var tfAuth: UITextField!
    @IBOutlet weak var btnAuth: UIButton!
    @IBOutlet weak var lbHintAuth: UILabel!
    @IBOutlet weak var underLineAuth: UIView!
    @IBOutlet weak var btnSignup: CButton!
    @IBOutlet weak var btnReset: CButton!
    
    @IBOutlet weak var btnSignin: CButton!
    let toolBar = CToolbar.init(barItems: [.keyboardDown])
    var timer: Timer?
    var authCode:String!
    var isCheckedAuth = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfPhone.inputAccessoryView = toolBar
        tfAuth.inputAccessoryView = toolBar
        toolBar.addTarget(self, selctor: #selector(onClickedBtnAction(_:)))
        lbHintPhone.text = ""
        lbHintAuth.text = ""
        
        self.addTapGestureKeyBoardDown()
        btnPhone.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
        self.stopTimer()
    }
    
    
    func stopTimer() {
        if let timer = self.timer {
            timer.invalidate()
            timer.fire()
        }
    }
    func startAuthTimer() {
        self.stopTimer()
        
        let endTimer = Date.timeIntervalSinceReferenceDate + (AUTH_TIMEOUT_MIN * 60)
        let diff:Int = Int(endTimer - Date.timeIntervalSinceReferenceDate)
        let minute = diff/60
        let second = (diff%60)
        let time = String(format: "%02ld:%02ld", minute, second)
        
        btnPhone.setTitle(time, for: .normal)
        btnPhone.setTitleColor(RGB(230, 100, 100), for: .normal)
        btnPhone.backgroundColor = RGB(230, 230, 230)
        
        btnPhone.isUserInteractionEnabled = false
        tfPhone.isUserInteractionEnabled = false
        
        tfAuth.becomeFirstResponder()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            let diff:Int = Int(endTimer - Date.timeIntervalSinceReferenceDate)
            if diff < 0 {
                self?.timeOut()
            }
            else {
                let minute = diff/60
                let second = (diff%60)
                let time = String(format: "%02ld:%02ld", minute, second)
                self?.btnPhone.setTitle(time, for: .normal)
            }
        }
    }
    
    func timeOut() {
        self.isCheckedAuth = false
        btnPhone.isUserInteractionEnabled = true
        btnPhone.setTitle("문자인증", for: .normal)
        btnPhone.setTitleColor(UIColor.white, for: .normal)
        btnPhone.backgroundColor = RGB(230, 100, 100)
        tfPhone.isUserInteractionEnabled = true
        
        stopTimer()
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        if sender.tag == TAG_TOOL_KEYBOARD_DOWN {
            self.view.endEditing(true)
        }
        else if sender == btnPhone {
            lbHintPhone.text = ""
            guard let phoneNum = tfPhone.text, phoneNum.isEmpty == false else {
                lbHintPhone.text = "전화번호를 입력해주세요."
                return
            }
            if phoneNum.validateKorPhoneNumber() == false {
                lbHintPhone.text = "전화번호 형식이 아닙니다."
                return
            }
            
            self.authCode = Utility.randomSms5digit()
            if phoneNum == "01010041004" {  //테스트 폰번호
                self.authCode = "12345"
            }
            let param = ["receiver":phoneNum, "service_key":"tiy1031", "contents":"오늘은너야인증번호[\(self.authCode!)]"];
            ApiManager.ins.requestSmsAuthCode(param: param) { (res) in
                let code = res["code"].stringValue
                if code == "000" {
                    self.startAuthTimer()
                }
                else {
                    let msg = res["msg"].stringValue
                    self.showErrorToast(msg)
                }
            } fail: { (err) in
                self.showErrorToast(err)
            }
        }
        else if sender == btnReset {
            self.stopTimer()
            self.authCode = ""
            tfPhone.isUserInteractionEnabled = true
            btnPhone.isUserInteractionEnabled = true
            btnPhone.backgroundColor = RGB(230, 100, 100)
            btnPhone.setTitle("문자인증", for: .normal)
            btnPhone.setTitleColor(UIColor.white, for: .normal)
            
            tfAuth.text = ""
            tfAuth.isUserInteractionEnabled = true
            btnAuth.isUserInteractionEnabled = true
            btnAuth.backgroundColor = RGB(230, 100, 100)
            btnAuth.setTitle("인증확인", for: .normal)
            btnAuth.setTitleColor(UIColor.white, for: .normal)
            
        }
        else if sender == btnAuth {
            lbHintAuth.text = ""
            guard let code = tfAuth.text, code.isEmpty == false else {
                lbHintAuth.text = "인증번호를 입력해주세요."
                return
            }
            if code != authCode {
                lbHintAuth.text = "인증번호가 일치하지 않습니다."
                return
            }
            
            AppDelegate.ins.startIndicator()
            self.stopTimer()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.isCheckedAuth = true
                
                self.tfAuth.isUserInteractionEnabled = false
                self.btnAuth.setTitle("인증완료", for: .normal)
                self.btnAuth.setTitleColor(RGB(230, 100, 100), for: .normal)
                self.btnAuth.backgroundColor = RGB(230, 230, 230)
                
                AppDelegate.ins.stopIndicator()
                
//                self.btnSignin.sendActions(for: .touchUpInside)
            }
        }
        else if sender == btnSignin {
            self.view.endEditing(true)
            guard isCheckedAuth == true, let phoneNumber = tfPhone.text, phoneNumber.isEmpty == false else {
                self.view.makeToast("로그인을 완료해주세요.")
                return
            }
            
            self.checkNewUser(phoneNumber)
        }
        else if sender == btnSignup {
            let vc = JoinTermsAgreeViewController.instantiateFromStoryboard(.login)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func checkNewUser(_ phoneNumber:String) {
        let newUserId = Utility.createUserId(phoneNumber)
        ApiManager.ins.requestUerInfo(param: ["user_id": newUserId]) { (res) in
            let isSuccess = res["isSuccess"]
            if isSuccess == "00" { //신규
//                CAlertViewController.show(type: .alert, title: nil, message: "존재하지 않는 회원입니다.", actions: [.ok], completion: nil)
                self.showToast("존재하지 않는 회원입니다.")
            }
            else if isSuccess == "01" {
                let userIdentifier = CipherManager.aes128EncrpytToHex(phoneNumber)
                KeychainItem.saveUserInKeychain(userIdentifier)
                
                ShareData.ins.setUserInfo(res)
                AppDelegate.ins.callMainViewCtrl()
            }
            else {
                self.showErrorToast(res)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfPhone {
            underLinePhone.backgroundColor = RGB(230, 100, 100)
        }
        else {
            underLineAuth.backgroundColor = RGB(230, 100, 100)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfPhone {
            underLinePhone.backgroundColor = RGB(216, 216, 216)
        }
        else {
            underLineAuth.backgroundColor = RGB(216, 216, 216)
        }
    }
}
