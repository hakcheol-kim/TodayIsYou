//
//  UIButton+Extension.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/22.
//

import Foundation
import UIKit
import AlamofireImage

extension UIButton {
    func setImageCache(_ url:String, _ placeholderImgName:String? = nil) {
        guard let reqUrl = URL(string: url) else {
            return
        }
        self.accessibilityIdentifier = reqUrl.absoluteString
        let request = URLRequest(url: reqUrl)
        
        imgDownloader.download(request, completion:  { response in
            if case .success(let image) = response.result {
                self.setImage(image, for: .normal)
            }
            else {
                guard let defaultImgName = placeholderImgName, let img = UIImage(named: defaultImgName) else {
                    return
                }
                self.setImage(img, for: .normal)
            }
        })
    }
    
    func addFlexableHeightConstraint() {
        self.constraints.forEach { const in
            if const.identifier == "height" {
                removeConstraint(const)
            }
        }
        self.titleLabel?.lineBreakMode = .byWordWrapping
        let height = self.sizeThatFits(CGSize(width: self.frame.size.width - self.contentEdgeInsets.left - self.contentEdgeInsets.right, height: 1000)).height

        self.translatesAutoresizingMaskIntoConstraints = false
        let hConst = heightAnchor.constraint(equalToConstant: height)
        hConst.identifier = "height"
        hConst.priority = UILayoutPriority(rawValue: 999)
        hConst.isActive = true
    }
}
