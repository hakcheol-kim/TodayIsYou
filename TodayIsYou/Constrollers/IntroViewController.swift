//
//  IntroViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/24.
//

import UIKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        requestUserInfo()
//        let arry = userInfo.split(separator: "|")
//        let joinType = arry.first
//        let identify = arry.last
//        UserDefaults.standard.setValue(userId, forKey: DfsKey.userId)
//        UserDefaults.standard.setValue(joinType, forKey: DfsKey.joinType)
//        UserDefaults.standard.setValue(identify, forKey: DfsKey.identifier)
//        UserDefaults.standard.synchronize()
//        ShareData.ins.userId = userId
    }
    
    //가입된 회원인지 조회한다.
    func requestUserInfo() {
        let userIdentifier = KeychainItem.currentUserIdentifier
        if (userIdentifier.isEmpty == true) {
            return
        }
        let userInfo = CipherManager.aes128Decrypt(toHex: userIdentifier)
        let userId = Utility.createUserId(userInfo)
        let param = ["app_type": appType, "user_id": userId]
        
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            let isSuccess = response?["isSuccess"]
            if isSuccess == "01" {
                //회원 맞음
            }
            else {
                AppDelegate.ins.callLoginViewCtrl()
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
}
