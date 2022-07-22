//
//  Clabel.swift
//  CustomViewExample
//
//  Created by 김학철 on 2020/06/25.
//  Copyright © 2020 김학철. All rights reserved.
//

import UIKit
@IBDesignable

class Clabel: UILabel {
    @IBInspectable var localizedKey: String? {
        didSet {
            guard let localizedKey = localizedKey else { return }
            UIView.performWithoutAnimation {
                self.text = localizedKey.localized
                layoutIfNeeded()
            }
        }
    }
    @IBInspectable var insetTB :CGFloat = 0.0 {
        didSet {
            if insetTB > 0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var insetLR :CGFloat = 0.0 {
        didSet {
            if insetLR > 0 { setNeedsDisplay() }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            if borderWidth > 0 {setNeedsDisplay()}
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            if borderColor != nil { setNeedsDisplay()}
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
        
        super.draw(rect)
        
        self.clipsToBounds = true
        var raduis:CGFloat = 0.0
        if borderWidth > 0 && borderColor != nil {
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = borderWidth
        }
        if halfCornerRadius {
            raduis = self.layer.bounds.height/2
        }
        else if cornerRadius > 0 {
            raduis = cornerRadius
        }
        
        self.layer.cornerRadius = raduis
        
        invalidateIntrinsicContentSize()
    }
    
    override func drawText(in rect: CGRect) {
        let inset = UIEdgeInsets.init(top: insetTB, left: insetLR, bottom: insetTB, right: insetLR)
        super.drawText(in: rect.inset(by: inset))
    }
    override var intrinsicContentSize: CGSize {
        let size:CGSize = super.intrinsicContentSize
        return CGSize.init(width: size.width + 2*insetLR, height: size.height + 2*insetTB)
    }
    
}
