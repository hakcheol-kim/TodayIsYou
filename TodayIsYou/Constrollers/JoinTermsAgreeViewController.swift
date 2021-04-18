//
//  JoinTermsAgreeViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/24.
//

import UIKit

class JoinTermsAgreeViewController: BaseViewController {
    @IBOutlet weak var btnSeviceCheck: UIButton!
    @IBOutlet weak var btnSeviceShow: UIButton!
    @IBOutlet weak var btnPrivacyCheck: UIButton!
    @IBOutlet weak var btnPrivacyShow: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var safeView: UIView!
    
    var user:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "약관 동의", #selector(actionNaviBack))
        safeView.isHidden = !Utility.isEdgePhone()
        
        let attr = NSAttributedString.init(string: "보 기", attributes:[NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        btnSeviceShow.setAttributedTitle(attr, for: .normal)
        btnPrivacyShow.setAttributedTitle(attr, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnSeviceCheck {
            sender.isSelected = !sender.isSelected
        }
        else if sender == btnPrivacyCheck {
            sender.isSelected = !sender.isSelected
        }
        else if sender == btnSeviceShow {
            self.requestTerm("yk1")
        }
        else if sender == btnPrivacyShow {
            self.requestTerm("yk2")
        }
        else if sender == btnOk {
            if btnSeviceCheck.isSelected == false || btnPrivacyCheck.isSelected == false {
                self.view.makeToast("약관에 동의해 주세요.")
                return
            }
            
            user["instantExperienceLaunched"] = false
            let vc = MemberInfoViewController.instantiateFromStoryboard(.login)!
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
 
    func requestTerm(_ mode: String) {
        
        ApiManager.ins.requestServiceTerms(mode: mode) { (response) in
            let yk = response["yk"].stringValue
            let isSuccess = response["isSuccess"]
            if isSuccess == "01", yk.isEmpty == false {
                let vc = TermsViewController.init()
                if mode == "yk1" {
                    vc.vcTitle = "서비스 이용약관"
                }
                else {
                    vc.vcTitle = "개인정보 취급방침"
                }
                vc.content = yk
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
}
