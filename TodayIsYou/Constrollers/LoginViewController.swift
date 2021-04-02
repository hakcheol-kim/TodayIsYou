//
//  LoginViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/23.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
class LoginViewController: SocialLoginViewController {

    @IBOutlet weak var btnKako: CButton!
    @IBOutlet weak var btnFacebook: CButton!
    @IBOutlet weak var btnNaver: CButton!
    @IBOutlet weak var btnApple: CButton!
    
    @IBOutlet weak var btnGoogleSignIn: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnGoogleSignIn.layer.cornerRadius = btnGoogleSignIn.bounds.height/2
        btnGoogleSignIn.clipsToBounds = true
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        btnGoogleSignIn.style = .wide
        
        for subView in btnGoogleSignIn.subviews {
            if let subView = subView as? UIImageView {
                subView.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        if sender == btnKako {
            self.loginWithType(.kakao) { (user, error) in
                guard let user = user, let joinType = user["joinType"], let userId = user["userId"] else {
                    print("naver login fail:\(String(describing: error))")
                    return
                }
                print("kakao login: joinType:\(joinType), userId:\(userId)")
                self.checkNewUser(user)
            }
        }
        else if sender == btnFacebook {
            self.loginWithType(.facebook) { (user, error) in
                guard let user = user, let joinType = user["joinType"], let userId = user["userId"] else {
                    print("naver login fail:\(String(describing: error))")
                    return
                }
                print("facebook login: joinType:\(joinType), userId:\(userId)")
                self.checkNewUser(user)
            }
        }
        else if sender == btnNaver {
            self.loginWithType(.naver) { (user, error) in
                guard let user = user, let _ = user["joinType"], let _ = user["userId"] else {
                    print("naver login fail:\(String(describing: error))")
                    return
                }
                self.checkNewUser(user)
            }
        }
        else if sender == btnApple {
            self.loginWithType(.apple) { (user, error) in
                guard let user = user, let _ = user["joinType"], let _ = user["userId"] else {
                    print("apple login fail:\(String(describing: error))")
                    return
                }
                
                self.checkNewUser(user)
            }
        }
    }
    
    func checkNewUser(_ user:[String:Any]) {
        let joinType: String = user["joinType"] as! String
        let userId: String = user["userId"] as! String
        let userInfo = "\(joinType)|\(userId)"
        
        let userIdentifier = CipherManager.aes128EncrpytToHex(userInfo)
        KeychainItem.saveUserInKeychain(userIdentifier)
        
        let newUserId = Utility.createUserId(userInfo)
        ApiManager.ins.requestUerInfo(param: ["user_id": newUserId]) { (res) in
            let isSuccess = res["isSuccess"]
            if isSuccess == "00" { //신규
                ShareData.ins.dfsSetValue(newUserId, forKey: DfsKey.userId)
                ShareData.ins.userId = newUserId
                let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "JoinTermsAgreeViewController") as! JoinTermsAgreeViewController
                let info = ["user_id":newUserId]
                vc.user = info
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if isSuccess == "01" {
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

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            return
        }
        
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        var userInfo: [String:Any] = [:]
        userInfo["joinType"] = "google"
        userInfo["userId"] = user.userID!
        if let idToken =  user.authentication.idToken {
            userInfo["accessToken"] = idToken
        }
        if let fullName = user.profile.name {
            userInfo["name"] = fullName
        }
        if let email = user.profile.email {
            userInfo["email"] = email
        }
        print("google sigin userId:\(user.userID!), email:\(user.profile.email!)")
        self.checkNewUser(userInfo)
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
