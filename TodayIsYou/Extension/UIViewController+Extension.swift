//
//  UIViewController+Extension.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/22.
//

import Foundation
import UIKit
import SwiftyJSON

//FIXME:: UIViewController
extension UIViewController {
    func setUserInterfaceStyle(_ interfaceStyle: UIUserInterfaceStyle) {
        if #available(iOS 13.0, *) {
            self.setValue(overrideUserInterfaceStyle, forKey:"overrideUserInterfaceStyle")
        }
    }
    class func instantiateFromStoryboard(_ name:Storyboard) -> Self? {
        let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
        let arrName = NSStringFromClass(self).components(separatedBy: ".")
        return storyboard.instantiateViewController(identifier: arrName.last!)
    }
    
    func showErrorToast(_ data: Any?) {
        if let data = data as? JSON {
            var msg:String = ""
            let message = data["errorMessage"].stringValue;
            let code = data["errorCode"].stringValue
            if message.isEmpty == false {
                msg.append("\(message)\nerror code : \(code)")
            }
            print("==== error: \(data)")
            if msg.isEmpty == true {
                return
            }
            appDelegate.window?.makeToast(msg)
        }
        else if let error = data as? CError, let msg = error.errorDescription {
            var findView:UIView = self.view
            for subview in self.view.subviews {
                if let subview = subview as? UIScrollView {
                    findView = subview
                    break
                }
            }
            findView.makeToast(msg)
        }
        else if let msg = data as? String {
            var findView:UIView = self.view
            for subview in self.view.subviews {
                if let subview = subview as? UIScrollView {
                    findView = subview
                    break
                }
            }
            findView.makeToast(msg)
        }
    }
    
    func myAddChildViewController(superView:UIView, childViewController:UIViewController) {
        addChild(childViewController)
//        childViewController.beginAppearanceTransition(true, animated: true)
        childViewController.willMove(toParent: self)
//        childViewController.view.frame = superView.bounds
        superView.addSubview(childViewController.view)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        childViewController.view.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        childViewController.view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        childViewController.view.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
//        childViewController.endAppearanceTransition()
        childViewController.didMove(toParent: self)
    }
    
    func myRemoveChildViewController(childViewController:UIViewController) {
//        childViewController.beginAppearanceTransition(true, animated: true)
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
//        childViewController.endAppearanceTransition()
    }

}
