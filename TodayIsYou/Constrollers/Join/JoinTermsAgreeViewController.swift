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
        CNavigationBar.drawBackButton(self, "login_term_title".localized, #selector(actionNaviBack))
        safeView.isHidden = !Utility.isEdgePhone()
        //약관보기
        let attr = NSAttributedString.init(string: "layout_txt86".localized, attributes:[NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        btnSeviceShow.setAttributedTitle(attr, for: .normal)
        btnPrivacyShow.setAttributedTitle(attr, for: .normal)
        btnSeviceCheck.titleLabel?.numberOfLines = 0
        btnPrivacyCheck.titleLabel?.numberOfLines = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
                self.view.makeToast(NSLocalizedString("join_activity47", comment: "서비스 이용약관에 동의하셔야 회원가입이 가능합니다."))
                return
            }
            
            user["instantExperienceLaunched"] = false
            let vc = MemberRegistViewController.instantiateFromStoryboard(.login)!
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
 
    func requestTerm(_ mode: String) {
        
        ApiManager.ins.requestServiceTerms(mode: mode) { (response) in
            let yk = response["yk"].stringValue
            if yk.isEmpty == false {
                let vc = TermsViewController.init()
                if mode == "yk1" {
                    vc.vcTitle = NSLocalizedString("login_term", comment: "서비스 이용약관");
                }
                else {
                    vc.vcTitle = NSLocalizedString("login_term", comment: "개인정보 취급방침")
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
