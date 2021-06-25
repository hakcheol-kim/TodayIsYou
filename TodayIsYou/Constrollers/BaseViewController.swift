//
//  BaseViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import Lightbox
import Photos

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let screen = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last {
            AdbrixEvent.addEventLog(.screenName, ["screenName": screen])
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func requestGetPoint() {
        ApiManager.ins.requestGetPoint(param: ["user_id" : ShareData.ins.myId]) { res in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                let point = res["point"].numberValue
                ShareData.ins.myPoint = point
                ShareData.ins.dfsSet(point, DfsKey.userPoint)
                appDelegate.mainViewCtrl.updateNaviPoint()
            }
        } failure: { error in
            self.showErrorToast(error)
        }
    }
    func requestMyInfo() {
        let param = ["app_type": appType, "user_id":ShareData.ins.myId]
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                ShareData.ins.setUserInfo(response)
                appDelegate.mainViewCtrl.updateNaviPoint()
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    public func requestMyHomePoint() {
        let param = ["user_id": ShareData.ins.myId]
        
        ApiManager.ins.requestMyHomePoint(param:param) { (respone) in
            let isSuccess = respone["isSuccess"].stringValue
            if isSuccess == "01" {
                ShareData.ins.setHomePoint(respone)
                appDelegate.mainViewCtrl.updateNaviPoint()
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
    func showToastWindow(_ msg: String?) {
        guard let msg = msg else {
            return
        }
        appDelegate.window?.makeToast(msg)
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
        
        if notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillHideNotification {
            
            let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
            
            let bottomConstraint = self.findBottomConstraint(self.view)
            
            
            guard let bottomCon = bottomConstraint, let conId = bottomCon.identifier else {
                return
            }
            
            var heightBtn:Float = 0.0
            let strH = conId.replacingOccurrences(of: "bottom_", with: "", options: [.caseInsensitive, .regularExpression])
            heightBtn = Float(strH) ?? 0.0
            
            if notification.name == UIResponder.keyboardWillShowNotification {
                var tabBarHeight:CGFloat = 0.0
                if self.navigationController?.tabBarController?.tabBar.isHidden == false {
                    tabBarHeight = self.navigationController?.toolbar.bounds.height ?? 0.0
                }
                
                let safeBottom:CGFloat = appDelegate.window?.safeAreaInsets.bottom ?? 0
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
    }
    func showPhoto(imgUrls:Array<String>) {
        if imgUrls.isEmpty == true {
            return
        }
    
        var images:[LightboxImage] = [LightboxImage]()
        for url in imgUrls {
            if let imgUrl = URL(string: url) {
                let lightbox = LightboxImage(imageURL: imgUrl)
                print(imgUrl)
                images.append(lightbox)
            }
        }
        let controller = LightboxController(images: images, startIndex: 0)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }    
}
