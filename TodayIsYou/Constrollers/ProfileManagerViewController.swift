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
    
    var selAge: String = "" {
        didSet {
            if let lbAge = btnAge.viewWithTag(100) as? UILabel {
                lbAge.text = selAge
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "프로필 수정", #selector(actionNaviBack))
        tfNickName.inputAccessoryView = accessoryView
        accessoryView.addTarget(self, selctor: #selector(actionKeybardDown))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
        requestMyInfo()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.removeKeyboardNotification()
    }
    
    func requestMyInfo() {
        ApiManager.ins.requestUerInfo(param: ["user_id":ShareData.ins.userId]) { (response) in
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
        lbGender.text = user_sex
        lbGender.textColor = RGB(125, 125, 125)
        
        self.selAge = user_age
        
        let ivProfile = btnProfile.viewWithTag(100) as! UIImageViewAligned
        if let url = Utility.thumbnailUrl(user_id, user_img) {
            ivProfile.setImageCache(url: url, placeholderImgName: nil)
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
        if sender == btnGender {
            self.showToast("성별은 변경이 불가합니다.")
        }
        else if sender == btnProfile {
            let vc = PhotoManagerViewController.instantiate(with: .profile)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnAge {
            guard let ageRange = ShareData.ins.getAge() else {
                return
            }
            let vc = PopupListViewController.initWithType(.normal, "선택해주세요.", ageRange, nil) { (vcs, selItem, index) in 
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? String else {
                    return
                }
                self.selAge = selItem
            }
            self.presentPanModal(vc)
        }
        else if sender == btnOk {
            guard let text = tfNickName.text, text.isEmpty == false else {
                self.showToast("닉네임을 입력해주세요.")
                return
            }
            guard text.length > 2 else {
                self.showToast("닉네은 3자 이상입니다.")
                return
            }
            
            let userName = userInfo["user_name"].stringValue
            let param = ["user_id":ShareData.ins.userId, "user_name":userName, "user_name_new": text,
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
    
}
extension ProfileManagerViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = RGB(230, 100, 100)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = RGB(216, 216, 216)
        }
    }
}
