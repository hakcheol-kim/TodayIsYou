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
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
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
            guard let nickname = tfNickName.text, nickname.isEmpty == false else {
                lbHintInfo.text = "닉네임을 입력해주세요."
                return
            }
            
            guard nickname.length  > 3 else {
                lbHintInfo.text = "3글자 이상 닉넴임을 입력해주세요."
                return
            }
            let cleanNickName =  ProfanityFilter.ins.cleanUp(nickname)
            tfNickName.text = cleanNickName
        }
    }
    
}

