//
//  ProfileManagerViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class ProfileManagerViewController: BaseViewController {
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var tfNickName: CTextField!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var btnAge: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    let accessoryView = CToolbar.init(barItems: [.keyboardDown])
    
    var userInfo:JSON!
    
    var selAge: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, NSLocalizedString("activity_txt467", comment: "프로필 수정"), #selector(actionNaviBack))
        tfNickName.inputAccessoryView = accessoryView
        accessoryView.addTarget(self, selctor: #selector(actionKeybardDown))
        
        if let ivCircle = btnProfile.viewWithTag(200) as? UIImageView {
            ivCircle.layer.cornerRadius = ivCircle.bounds.height/2;
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.addKeyboardNotification()
        requestMyInfo()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        super.removeKeyboardNotification()
    }
    
    override func requestMyInfo() {
        let param = ["app_type": appType, "user_id": ShareData.ins.myId]
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            self.userInfo = response
            self.decorationUi()
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    func decorationUi() {
        let user_name = userInfo["user_name"].stringValue
        let user_sex = userInfo["user_sex"].stringValue
        let user_age = userInfo["user_age"].stringValue
        let user_img = userInfo["user_img"].stringValue
        let user_id = userInfo["user_id"].stringValue
        
        tfNickName.text = user_name
        let lbGender = btnGender.viewWithTag(100) as! UILabel
        lbGender.text = Gender.localizedString(user_sex)
        lbGender.textColor = RGB(125, 125, 125)
        
        if selAge.isEmpty == true {
            selAge = user_age
        }
        if let lbAge = btnAge.viewWithTag(100) as? UILabel {
            lbAge.text = Age.localizedString(selAge)
        }
        
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
        if sender == btnGender {
            self.showToast(NSLocalizedString("not_changed_gender", comment: "성별은 변경이 불가합니다."))
        }
        else if sender == btnProfile {
            let vc = PhotoManagerViewController.instantiate(with: .profile)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnAge {
            var ageRange = [String]()
            for i in 26..<33 {
                let key = String(format: "root_display_txt%02ld", i)
                ageRange.append(NSLocalizedString(key, comment: ""))
            }
            
            let vc = PopupListViewController.initWithType(.normal, NSLocalizedString("popup_tilte_select", comment: "선택해주세요."), ageRange, nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? String else {
                    return
                }
                self.selAge = Age.severKey(selItem)
                if let lbAge = self.btnAge.viewWithTag(100) as? UILabel {
                    lbAge.text = Age.localizedString(self.selAge)
                }
            }
            self.presentPanModal(vc)
        }
        else if sender == btnOk {
            guard let text = tfNickName.text, text.isEmpty == false else {
                self.showToast(NSLocalizedString("join_activity06", comment: "닉네임을 입력해주세요."))
                return
            }
            guard text.length > 2 else {
                self.showToast(NSLocalizedString("join_nickname_check", comment: "3글자 이상 닉넴임을 입력해주세요."))
                return
            }
            
            let userName = userInfo["user_name"].stringValue
            let param = ["user_id":ShareData.ins.myId, "user_name":userName, "user_name_new": text,
                         "user_age":selAge, "user_sex":userInfo["user_sex"].stringValue]
            
            ApiManager.ins.requestUpdateUerInfo(param: param) { (res) in
                let isSuccess = res["isSuccess"].stringValue
                if isSuccess == "01" {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showErrorToast(res)
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
    }
    @objc func checkNicknameProfanity() {
        guard let text = tfNickName.text, text.isEmpty == false else {
            return
        }
        let profanNickname = ProfanityFilter.ins.cleanUp(text)
        tfNickName.text = profanNickname
    }
}

extension ProfileManagerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        ProfileManagerViewController.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkNicknameProfanity), object: nil)
        
        guard let text = textField.text as NSString? else {
            return false
        }
        let newString = text.replacingCharacters(in: range, with: string)
        perform(#selector(checkNicknameProfanity), with: nil, afterDelay: 0.3)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = RGB(230, 100, 100)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = RGB(216, 216, 216)
        }
        if textField == tfNickName {
            self.checkNicknameProfanity()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
