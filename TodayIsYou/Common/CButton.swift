//
//  CButton.swift
//  CustomViewExample
//
//  Created by 김학철 on 2020/06/29.
//  Copyright © 2020 김학철. All rights reserved.
//

import UIKit
import CoreGraphics

func imageFromColor(color: UIColor) -> UIImage {
    let rect: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}

class CButton: UIButton {
    var borderLayer: CALayer?
    public var data: Any!
    
    @IBInspectable var isBoderBottom: Bool = false {
        didSet {
            if isBoderBottom == true { setNeedsDisplay() }
        }
    }
    @IBInspectable var isBoderAll: Bool = false {
        didSet {
            if isBoderAll == true { setNeedsDisplay() }
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            if borderWidth > 0 {setNeedsDisplay()}
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var halfCornerRadius:Bool = false {
        didSet {
            if halfCornerRadius {setNeedsDisplay()}
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius > 0 { setNeedsDisplay()}
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        if isBoderBottom {
            if let borderLayer = borderLayer {
                borderLayer.removeFromSuperlayer()
            }
            
            self.borderLayer = CALayer()
            self.borderLayer!.backgroundColor = borderColor?.cgColor
            self.borderLayer!.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)

            layer.addSublayer(borderLayer!)
            layer.masksToBounds = true
        }
        else if isBoderAll {
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor?.cgColor
        }
        
        if halfCornerRadius {
            self.clipsToBounds = true
            self.layer.cornerRadius = self.bounds.height/2
        }
        else if cornerRadius > 0 {
            self.clipsToBounds = true
            self.layer.cornerRadius = cornerRadius
        }
    }

}
