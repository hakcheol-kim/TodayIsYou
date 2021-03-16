//
//  BaseViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
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
            if const.identifier == "bottom" {
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
 
        //scrollView bottom constraint identyfier "bottom" 정의해야한다.
        let findConst = self.findBottomConstraint(self.view)
        guard let bottomContainer = findConst else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            var tabBarHeight:CGFloat = 0.0
            if self.navigationController?.tabBarController?.tabBar.isHidden == false {
                tabBarHeight = self.navigationController?.toolbar.bounds.height ?? 0.0
            }
            
            let safeBottom:CGFloat = self.view.window?.safeAreaInsets.bottom ?? 0
            bottomContainer.constant = heightKeyboard - safeBottom - tabBarHeight
            UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                self.view.layoutIfNeeded()
            })
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomContainer.constant = 0
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
