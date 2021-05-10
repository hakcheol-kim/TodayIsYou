//
//  CToat.swift
//  StartCode
//
//  Created by 김학철 on 2020/12/30.
//

import Foundation
import UIKit
let tagBottomTostView = 1234236
let tagTostView = 1234235

public extension UIView {
    
    enum CToastPosition: Int {
        case top, center, bottom
    }
    
    func makeToast(_ message: Any?, duration: TimeInterval = 5, position: CToastPosition = .bottom) {
        
        if let btnToast = self.viewWithTag(tagTostView) as? UIButton {
            btnToast.removeFromSuperview()
        }
        if let btnToast = AppDelegate.ins.window?.viewWithTag(tagTostView) as? UIButton {
            btnToast.removeFromSuperview()
        }
        
        let btnToast = UIButton.init(type: .custom)
        btnToast.tag = tagTostView
        
        self.addSubview(btnToast)
        btnToast.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        if let message = message as? NSAttributedString {
            btnToast.setAttributedTitle(message, for: .normal)
        }
        else if let message = message as? String {
            btnToast.setTitle(message, for: .normal)
        }
        btnToast.setTitleColor(UIColor.white, for: .normal)
        btnToast.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btnToast.titleLabel?.numberOfLines = 0
        btnToast.layer.cornerRadius = 8
        btnToast.backgroundColor = RGBA(0, 0, 0, 0.8)
        
        btnToast.translatesAutoresizingMaskIntoConstraints = false
        btnToast.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        btnToast.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        let fitSize = btnToast.titleLabel?.sizeThatFits(CGSize(width: self.bounds.width-60, height: CGFloat.greatestFiniteMagnitude))
        btnToast.widthAnchor.constraint(equalToConstant: (fitSize?.width ?? 0) + 24).isActive = true
        btnToast.heightAnchor.constraint(equalToConstant: (fitSize?.height ?? 0) + 16).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+duration) {
            if let btn = self.viewWithTag(tagTostView) as? UIButton {
                btn.removeFromSuperview()
            }
        }
    }
    
    func makeBottomTost(_ message: Any?, duration: TimeInterval = 5, _ font:UIFont = UIFont.systemFont(ofSize: 15), _ titleColor:UIColor = .white, _ bgColor:UIColor = UIColor(red: 0.902, green: 0.392, blue: 0.392, alpha: 1.0)) {
        guard let message = message else {
            return
        }
        
        if let toast = self.viewWithTag(tagBottomTostView) {
            toast.removeFromSuperview()
        }
        
        let toast = UIView.init()
        self.addSubview(toast)
        toast.backgroundColor = bgColor
        toast.tag = tagBottomTostView
        
//        toast.layer.borderWidth = 1.0
//        toast.layer.borderColor = UIColor.blue.cgColor
        
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        toast.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        toast.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        let btn = UIButton.init()
        toast.addSubview(btn)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 16).isActive = true
        btn.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -16).isActive = true
        btn.topAnchor.constraint(equalTo: toast.topAnchor, constant: 8).isActive = true
        btn.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        btn.titleLabel?.numberOfLines = 0
        btn.setTitleColor(titleColor, for: .normal)
//        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = font
        
//        btn.layer.borderWidth = 1.0
//        btn.layer.borderColor = UIColor.yellow.cgColor
        
        if let message = message as? String {
            btn.setTitle(message, for: .normal)
        }
        else if let message = message as? NSAttributedString {
            btn.setAttributedTitle(message, for: .normal)
        }
        
        let fitheight = btn.sizeThatFits(CGSize(width: self.bounds.width - 32, height: CGFloat.greatestFiniteMagnitude)).height
        
        btn.heightAnchor.constraint(equalToConstant: fitheight).isActive = true
        self.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+duration) {
            if let toast = self.viewWithTag(tagBottomTostView) {
                toast.removeFromSuperview()
            }
        }
        AppDelegate.ins.window?.bringSubviewToFront(toast)
    }
    
}
