//
//  PulseButton.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/25.
//

import UIKit
import AVFoundation
class PulseButton: UIButton {

    @IBInspectable var pulseColor: UIColor = UIColor.white {
        didSet {
        }
    }
    @IBInspectable var pulseDuration: CGFloat = 1.0 {
        didSet {}
    }
    @IBInspectable var pulseRadius: CGFloat = 1.0 {
        didSet {}
    }
    
    var isAnimated: Bool = false {
        didSet {
            self.handleAnimations()
//            if isAnimated {
//                self.setImage(UIImage(named: "ico_bell"), for: .normal)
//            }
//            else {
//                self.setImage(UIImage(named: "ico_bell"), for: .normal)
//            }
        }
    }
    lazy var mainLayer: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.backgroundColor = pulseColor.cgColor
        layer.bounds = self.bounds
        layer.cornerRadius = self.bounds.width/2
        layer.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        layer.zPosition = -1
        return layer
    }()
    
    lazy var pulseLayer: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.backgroundColor = pulseColor.cgColor
        layer.bounds = self.bounds
        layer.cornerRadius = self.bounds.size.width/2;
        layer.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        layer.zPosition = -2
        layer.opacity = 0
        return layer
    }()

    lazy var scaleAnimationLayer: CABasicAnimation = {
        let scale = CABasicAnimation(keyPath: "transform.scale.xy")
        scale.fromValue = NSNumber(value: 1.0)
        scale.toValue = NSNumber(value: Float(pulseRadius+1.0))
        scale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return scale
    }()
    
    lazy var opacityAnimation: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [
            NSNumber(value: 0.8),
            NSNumber(value: 0.4),
            NSNumber(value: 0.0)
        ]
        animation.keyTimes = [
            NSNumber(value: 0.0),
            NSNumber(value: 0.5),
            NSNumber(value: 1.0)
        ]
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return animation
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addSublayer(mainLayer)
    }
    
    private func handleAnimations() {
        if isAnimated == false {
            return;
        }
        self.layer.insertSublayer(pulseLayer, below: mainLayer)
        let group = CAAnimationGroup.init()
        group.animations = [scaleAnimationLayer, opacityAnimation]
        group.duration = CFTimeInterval(pulseDuration)
        pulseLayer.add(group, forKey: "pulse")
        
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(0.5), execute: {
            weakSelf?.handleAnimations()
        })
    }
    
}
