//
//  LoginViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/23.
//

import UIKit

class LoginViewController: SocialLoginViewController {

    @IBOutlet weak var btnKako: CButton!
    @IBOutlet weak var btnFacebook: CButton!
    @IBOutlet weak var btnNaver: CButton!
    @IBOutlet weak var btnApple: CButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        if sender == btnKako {
            self.loginWithType(.kakao) { (user, error) in
                
            }
        }
        else if sender == btnFacebook {
            self.loginWithType(.facebook) { (user, error) in
                
            }
        }
        else if sender == btnNaver {
            self.loginWithType(.naver) { (user, error) in
                
            }
        }
        else if sender == btnApple {
            self.loginWithType(.apple) { (user, error) in
                guard let user = user, let joinType = user["joinType"], let userId = user["userId"] else {
                    print("apple login fail:\(String(describing: error))")
                    return
                }
                
                let userInfo = "\(joinType)|\(userId)"
                let userIdentifier = CipherManager.aes128EncrpytToHex(userInfo)
                KeychainItem.saveUserInKeychain(userIdentifier)
                
                guard let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "JoinTermsAgreeViewController") as? JoinTermsAgreeViewController else {
                    return
                }
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
