//
//  BaseViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func reqGetPoint() {
        let param = ["user_id": ShareData.ins.userId]
        ApiManager.ins.requestGetPoint(param:param) { (respone) in
            if let respone = respone {
                let point = respone["point"].numberValue
                ShareData.ins.dfsSetValue(point, forKey: DfsKey.myPoint)
                AppDelegate.ins.mainViewCtrl.updateNaviPoint()
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    func showToast(_ message:String?) {
        guard let message = message, message.isEmpty == false else {
            return
        }
        var findView:UIView = self.view
        if let subView = self.view.subviews.first as? UIScrollView {
            findView = subView
        }
        else if let subView = self.view.subviews.first as? UITableView {
            findView = subView
        }
        
        if message.contains("<") {
            do {
                let attr = try NSMutableAttributedString.init(htmlString: message)
                attr.addAttribute(.foregroundColor, value: UIColor.white, range: NSMakeRange(0, attr.string.length))
                findView.makeToast(attr)
            }
            catch {
            }
        }
        else {
            findView.makeToast(message)
        }
    }
    
    @objc public func actionNaviBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addTapGestureKeyBoardDown() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        self.view.addGestureRecognizer(tap)
    }
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
    }
    @objc func actionKeybardDown() {
        self.view.endEditing(true)
    }
    func findBottomConstraint(_ view: UIView) -> NSLayoutConstraint? {
        var findConst:NSLayoutConstraint? = nil
        for const in view.constraints {
            if let conId = const.identifier, conId.contains("bottom") == true {
                findConst = const
                break
            }
        }
        return findConst
    }
    //키보드 노티 피케이션 핸들러
    @objc func notificationHandler(_ notification: NSNotification) {
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
        
        let bottomConstraint = self.findBottomConstraint(self.view)
        
        
        guard let bottomCon = bottomConstraint, let conId = bottomCon.identifier else {
            return
        }
        
        var heightBtn:Float = 0.0
        let strH = conId.replacingOccurrences(of: "bottom", with: "", options: [.caseInsensitive, .regularExpression])
        heightBtn = Float(strH) ?? 0.0
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            var tabBarHeight:CGFloat = 0.0
            if self.navigationController?.tabBarController?.tabBar.isHidden == false {
                tabBarHeight = self.navigationController?.toolbar.bounds.height ?? 0.0
            }
            
            let safeBottom:CGFloat = self.view.window?.safeAreaInsets.bottom ?? 0
            bottomCon.constant = heightKeyboard - safeBottom - tabBarHeight - CGFloat(heightBtn)
            UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                self.view.layoutIfNeeded()
            })
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomCon.constant = 0
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
//    let appleIDProvider = ASAuthorizationAppleIDProvider()
//    appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
//        switch credentialState {
//        case .authorized:
//            break // The Apple ID credential is valid.
//        case .revoked, .notFound:
//            // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
//            DispatchQueue.main.async {
//                self.window?.rootViewController?.showLoginViewController()
//            }
//        default:
//            break
//        }
//    }
//    return true
//}
//    @IBAction func signOutButtonPressed() {
//        // For the purpose of this demo app, delete the user identifier that was previously stored in the keychain.
//        KeychainItem.deleteUserIdentifierFromKeychain()
//
//        // Clear the user interface.
//        userIdentifierLabel.text = ""
//        givenNameLabel.text = ""
//        familyNameLabel.text = ""
//        emailLabel.text = ""
//
//        // Display the login controller again.
//        DispatchQueue.main.async {
//            self.showLoginViewController()
//        }
//    }
}
