//
//  CTextView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit
import Foundation

@IBDesignable class CTextView: UITextView {
    public var placeholderLabel: UILabel?
    private var isOnceLoad: Bool = false
    
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
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius > 0 { setNeedsDisplay()}
        }
    }
    
    @IBInspectable var insetTop: CGFloat = 0.0 {
        didSet {
            if insetTop > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var insetBottom: CGFloat = 0.0 {
        didSet {
            if insetBottom > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var insetLeft: CGFloat = 0.0 {
        didSet {
            if insetLeft > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var insetRigth: CGFloat = 0.0 {
        didSet {
            if insetRigth > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var isCenterTextAligment:Bool = false {
        didSet {
            if isCenterTextAligment { setNeedsDisplay() }
        }
    }
    @IBInspectable var placeHolderColor: UIColor = UIColor(white: 0.78, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var placeHolderString: String? {
        didSet {
            if placeHolderString != nil {
                setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.textContainer.lineFragmentPadding = 0.0
        self.textContainerInset = UIEdgeInsets.init(top: insetTop, left: insetLeft, bottom: insetBottom, right: insetRigth)
        if let _ = placeHolderString {
            self.configurePlaceholderLabel()
        }
        
        if isCenterTextAligment && isOnceLoad == false {
            self.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            isOnceLoad = true
        }
        if borderWidth > 0 && borderColor != nil {
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = borderWidth
        }
        
        if cornerRadius > 0 {
            self.clipsToBounds = true
            self.layer.cornerRadius = cornerRadius
        }
    }
//    override var text: String! {
//        didSet {
//            textViewDidChange(self)
//        }
//    }
    func configurePlaceholderLabel() {
        
        if let placeholderLabel = placeholderLabel {
            placeholderLabel.removeFromSuperview()
        }
        placeholderLabel = UILabel()
        placeholderLabel?.font = font
        placeholderLabel?.textColor? = placeHolderColor
        placeholderLabel?.text = placeHolderString
        placeholderLabel?.numberOfLines = 0
        
        self.addSubview(placeholderLabel!)
        
        placeholderLabel?.translatesAutoresizingMaskIntoConstraints = false
        let leading = (placeholderLabel?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insetLeft))!
        leading.priority = UILayoutPriority(rawValue: 999)
        leading.isActive = true
        
        let top = (placeholderLabel?.topAnchor.constraint(equalTo: self.topAnchor, constant: insetTop))!
        top.priority = UILayoutPriority(rawValue: 999)
        top.isActive = true
        
        let right = (placeholderLabel?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: insetRigth))!
        right.priority = UILayoutPriority(rawValue: 999)
        right.isActive = true
        
        let bottom = (placeholderLabel?.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: insetBottom))!
        bottom.priority = UILayoutPriority(rawValue: 999)
        bottom.isActive = true
        
        placeholderLabel?.isHidden = !self.text.isEmpty
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let textView = object as? UITextView {
            var topoffset = (textView.bounds.size.height - (textView.contentSize.height * textView.zoomScale))/2.0
            if topoffset < 0.0 {
                topoffset = 0.0
            }
            
            textView.contentOffset = CGPoint(x: 0, y: -topoffset)
        }
    }
//    func textViewDidChange(_ textView: UITextView) {
//        placeholderLabel?.isHidden = !textView.text.isEmpty
//    }
    
}
 
