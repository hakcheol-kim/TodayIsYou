//
//  LoginViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/23.
//

import UIKit
class LoginViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        
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
                ShareData.ins.dfsSet(newUserId, DfsKey.userId)
                ShareData.ins.myId = newUserId
                let vc = JoinTermsAgreeViewController.instantiateFromStoryboard(.login)!
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
