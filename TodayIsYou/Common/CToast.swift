//
//  CToat.swift
//  StartCode
//
//  Created by 김학철 on 2020/12/30.
//

import Foundation
import UIKit


public extension UIView {
    
    enum CToastPosition: Int {
        case top, center, bottom
    }
    
    func makeToast(_ message: Any?, duration: TimeInterval = 5, position: CToastPosition = .bottom) {
        
        let tagTostLabel:Int = 1234235
        if let btnToast = self.viewWithTag(tagTostLabel) as? UIButton {
            btnToast.removeFromSuperview()
        }
        let btnToast = UIButton.init(type: .custom)
        btnToast.tag = tagTostLabel
        self.addSubview(btnToast)
        btnToast.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        if let message = message as? NSAttributedString {
            btnToast.setAttributedTitle(message, for: .normal)
        }
        else if let message = message as? String {
            btnToast.setTitle(message, for: .normal)
        }
        btnToast.setTitleColor(UIColor.white, for: .normal)
        btnToast.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
            if let btn = self.viewWithTag(tagTostLabel) as? UIButton {
                btn.removeFromSuperview()
            }
        }
    }
}
