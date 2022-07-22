//
//  CImageView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/10.
//

import UIKit

class CImageView: UIImageView {
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
            if halfCornerRadius {self.setNeedsDisplay() }
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius > 0 { setNeedsDisplay()}
        }
    }
    
    @IBInspectable var sdColor: UIColor? {
        didSet {
            if sdColor != nil { setNeedsDisplay() }
        }
    }
    @IBInspectable var sdOffset:CGSize = CGSize.zero {
        didSet {
            if sdOffset.width > 0 || sdOffset.height > 0 { setNeedsDisplay()}
        }
    }
    @IBInspectable var sdRadius: CGFloat = 0.0 {
        didSet {
            if sdRadius > 0 {setNeedsDisplay()}
        }
    }
    @IBInspectable var sdOpacity: Float = 0.0 {
        didSet {
            if sdOpacity > 0 { setNeedsDisplay()}
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        if borderWidth > 0 && borderColor != nil {
            self.clipsToBounds = true
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = borderWidth
        }
        
        if halfCornerRadius {
            self.clipsToBounds = true
            self.layer.cornerRadius = self.bounds.height/2
        }
        else if cornerRadius > 0 {
            self.clipsToBounds = true
            self.layer.cornerRadius = cornerRadius
        }
        
        if let sColor = sdColor {
            layer.masksToBounds = false
            layer.shadowOffset = sdOffset
            layer.shadowColor = sColor.cgColor
            layer.shadowRadius = sdRadius
            layer.shadowOpacity = sdOpacity
            backgroundColor = nil
        }
    }
}
