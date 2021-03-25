//
//  CNavigationBar.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/27.
//

import UIKit
public let TAG_NAVI_BACK: Int = 10000
public let TAG_NAVI_TITLE: Int = 10001
public let TAG_NAVI_POINT: Int = 10002
public let TAG_NAVI_P_COINT: Int = 10003
public let TAG_NAVI_S_COINT: Int = 10004

public let ColorNaviBar = RGB(230, 50, 70)

class CNavigationBar: UINavigationBar {
    class func drawBackButton(_ controller: UIViewController, _ title: String, _ selector:Selector?) {
        CNavigationBar.drawLeftBarItem(controller, UIImage(systemName: "chevron.left"), title, TAG_NAVI_BACK, selector)
    }
    class func drawLeftBarItem(_ controller: UIViewController, _ image: UIImage?, _ title: String?, _ tag:Int, _ selector:Selector?) {
        
        controller.navigationController?.setNavigationBarHidden(false, animated: true)
        let button: UIButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.tintColor = UIColor.label
        
        button.tag = tag
        
        if let image = image {
            button.setImage(image, for: .normal)
        }
        
        if let title = title {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            var width: CGFloat = button.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: button.frame.size.height)).width
            if width > 250 {
                width = 250
            }
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            
            button.frame = CGRect.init(x: 0, y: 0, width: width + button.titleEdgeInsets.left, height: button.frame.size.height)
        }
       
        let barBtn = UIBarButtonItem.init(customView: button)
        barBtn.tag = TAG_NAVI_BACK
        controller.navigationItem.setLeftBarButton(barBtn, animated: false)
        if let selector = selector {
            button.addTarget(controller, action: selector, for: .touchUpInside)
        }
        button.tintColor = UIColor.white
        button.setTitleColor(button.tintColor, for: .normal)
        
        let naviBar = controller.navigationController?.navigationBar
        naviBar?.isTranslucent = true
        let img = UIImage.image(from: ColorNaviBar)!
        naviBar?.tintColor = UIColor.white
        naviBar?.barTintColor = UIColor.white
        naviBar?.setBackgroundImage(img, for: UIBarMetrics.default)
        naviBar?.shadowImage = UIImage.init()
        UINavigationBar.appearance().shadowImage = UIImage.init()
    }
    
    class func drawTitle(_ controller: UIViewController, _ title: Any?, _ selctor:Selector?) {
        let button: UIButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        button.setTitleColor(UIColor.white, for: .normal)
        if let title:String = title as? String {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
        }
        else if let title:UIImage = title as? UIImage {
            button.setImage(title, for: .normal)
        }
        
        var width: CGFloat = button.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: button.frame.size.height)).width
        if width > 250.0 {
            width = 250
        }
        button.frame = CGRect.init(x: 0, y: 0, width: width, height: button.frame.size.height)
        button.adjustsImageWhenHighlighted = false
        button.adjustsImageWhenDisabled = false
        
        controller.navigationItem.titleView = button;
        
        
        if let selctor = selctor {
            button.addTarget(controller, action: selctor, for: .touchUpInside)
        }
        button.tintColor = UIColor.white
        let naviBar = controller.navigationController?.navigationBar
        button.tintColor = UIColor.white
        naviBar?.isTranslucent = true
        let img = UIImage.image(from: ColorNaviBar)!
        naviBar?.tintColor = UIColor.white
        naviBar?.barTintColor = UIColor.white
        naviBar?.setBackgroundImage(img, for: UIBarMetrics.default)
        naviBar?.shadowImage = UIImage.init()
        UINavigationBar.appearance().shadowImage = UIImage.init()
    }
    
    class func drawRight(_ controller: UIViewController, _ img:UIImage?, _ title: String?, _ tag:Int,  _ selctor:Selector?) {
        
        let button: UIButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.tag = tag
        button.tintColor = UIColor.white
        if let img = img {
            button.setImage(img, for: .normal)
        }
        
        if let title = title {
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            
            button.setTitle(title, for: .normal)
            
            let width: CGFloat = button.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: button.frame.size.height)).width
//            if width > 250.0 {
//                width = 250
//            }
//            else if width < 44 {
//                width = 44
//            }
            button.frame = CGRect.init(x: 0, y: 0, width: width + 8, height: button.frame.size.height)
        }
//        button.layer.borderColor = UIColor.white.cgColor;
//        button.layer.borderWidth = 1.0
        if let selctor = selctor {
            button.addTarget(controller, action: selctor, for: .touchUpInside)
        }
        
        let barBtn = UIBarButtonItem.init(customView: button)
        if var items = controller.navigationItem.rightBarButtonItems, items.isEmpty == false {
            items.append(barBtn)
            controller.navigationItem.setRightBarButtonItems(items, animated: false)
        }
        else {
            controller.navigationItem.setRightBarButton(barBtn, animated: false)
        }
        
        let naviBar = controller.navigationController?.navigationBar
        button.tintColor = UIColor.white
        button.setTitleColor(button.tintColor, for: .normal)
        
        naviBar?.isTranslucent = true
        let img = UIImage.image(from: ColorNaviBar)
        naviBar?.tintColor = UIColor.white
        naviBar?.barTintColor = UIColor.white
        naviBar?.setBackgroundImage(img, for: UIBarMetrics.default)
        naviBar?.shadowImage = UIImage.init()
        UINavigationBar.appearance().shadowImage = UIImage.init()
    }
}
