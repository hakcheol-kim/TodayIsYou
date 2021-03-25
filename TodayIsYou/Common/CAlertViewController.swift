//
//  CAlertViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/19.
//

import UIKit
enum CAletType {
    case alert
}
enum CAletActionType {
    case ok, cancel, normal
}

typealias CAletClosure = (_ vcs:CAlertViewController, _ selItem:Any?, _ index:Int) ->Void

class CAlertViewController: UIViewController {
    @IBOutlet weak var svContainer: UIStackView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var svMsg: UIStackView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var svButton: UIStackView!
    @IBOutlet weak var containerView: CView!
    @IBOutlet weak var btnsView: UIView!
    @IBOutlet weak var bottmContainerView: NSLayoutConstraint!
    @IBOutlet weak var shadowView: CView!
    @IBOutlet weak var heightBtn: NSLayoutConstraint!
    
    @IBOutlet weak var btnFullClose: UIButton!
    var isBackGroundTouchClose: Bool = true
    var fontMsg: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    var fontTitle: UIFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    var contentInset:UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    var type: CAletType = .alert
    var aletTitle: Any?
    var message: Any?
    var completion: CAletClosure?
    
    var arrBtn:Array<UIButton> = []
    var arrTextView:[CTextView] = []
    var actions:[CAletActionType]?
    
    convenience init(_ type:CAletType, _ title:Any? = nil, _ message:Any? = nil, _ actions:[CAletActionType]?, completion:CAletClosure?) {
        self.init()
        self.type = type
        self.aletTitle = title
        self.message = message
        self.actions = actions
        self.completion = completion
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 8
        containerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: true, BR: true)
//        containerView.clipsToBounds = true
        
        self.reloadUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.endEditing(true)
    }
    
    func reloadUI() {
        self.view.layoutIfNeeded()
        
        titleView.isHidden = true
        if let aletTitle = aletTitle as? NSAttributedString {
            lbTitle.font = fontTitle
            titleView.isHidden = false
            lbTitle.attributedText = aletTitle
        }
        else if let aletTitle = aletTitle as? String {
            lbTitle.font = fontTitle
            titleView.isHidden = false
            lbTitle.text = aletTitle
        }
        
        for subview in svContent.subviews {
            subview.removeFromSuperview()
        }
        
        if let message = message as? NSAttributedString {
            let lbMsg = UILabel.init()
            lbMsg.textAlignment = .center
            lbMsg.font = fontMsg
            lbMsg.attributedText = message
            svMsg.addArrangedSubview(lbMsg)
        }
        else if let message = message as? String {
            let lbMsg = UILabel.init()
            lbMsg.textAlignment = .center
            lbMsg.font = fontMsg
            lbMsg.text = message
            svMsg.addArrangedSubview(lbMsg)
        }
        
        if let actions = actions {
            for subview in svButton.subviews {
                subview.removeFromSuperview()
            }
            for action in actions {
                if (action == .ok) {
                    self.addAction(action, "확인")
                }
                else if (action == .cancel) {
                    self.addAction(action, "취소")
                }
            }
        }
    }
    func addCustomView(_ view:UIView) {
        self.view.layoutIfNeeded()
        self.containerView.backgroundColor = UIColor.clear
        
        svContent.isHidden = true
        svContainer.insertArrangedSubview(view, at: 0)
    }
    func addAction(_ actionType:CAletActionType, _ title:String? = nil, _ img: UIImage? = nil, _ tintColor: UIColor? = UIColor.lightGray) {
        self.view.layoutIfNeeded()
        self.view.layer.borderColor = UIColor.clear.cgColor
        
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.clipsToBounds = true
        btn.backgroundColor = UIColor.white
        
        if let img = img {
            btn.setImage(img, for: .normal)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            btn.tintColor = tintColor
        }
        
        if let title = title {
            btn.setTitle(title, for: .normal)
        }
        
        if actionType == .ok {
            btn.setTitleColor(RGB(230, 100, 100), for: .normal)
        }
        else if actionType == .cancel {
            btn.setTitleColor(RGB(125, 125, 125), for: .normal)
        }
        else {
            btn.setTitleColor(UIColor.label, for: .normal)
        }
        
        btnsView.isHidden = false
        svButton.addArrangedSubview(btn)
        btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        btn.tag = 100+arrBtn.count
        arrBtn.append(btn)
    }
    
    func addTextView(_ placeholder: String? = nil,_ font: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular), _ edge: UIEdgeInsets = .zero) {
        self.view.layoutIfNeeded()
        let tv = CTextView.init()
        svContent.addArrangedSubview(tv)
        if let placeholder = placeholder {
            tv.placeHolderString = placeholder
        }
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.heightAnchor.constraint(equalToConstant: 120).isActive = true
        tv.font = font
        
        tv.insetLeft = 0
        tv.insetTop = 0
        tv.insetBottom = 0
        tv.insetRigth = 0
        tv.setNeedsDisplay()
        
        arrTextView.append(tv)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnFullClose {
            if arrTextView.isEmpty == false {
                self.view.endEditing(true)
            }
            else {
                self.dismiss(animated: false, completion: nil)
            }
        }
        else {
            if arrTextView.isEmpty == false {
                if let textView = arrTextView.first, textView.text.isEmpty == true {
                    return
                }
                self.completion?(self, nil, sender.tag-100)
            }
            else {
                self.completion?(self, nil, sender.tag-100)
            }
        }
    }
    
    @objc func notificationHandler(_ notification: Notification) {
        if notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillHideNotification {
            
            let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
     
            if notification.name == UIResponder.keyboardWillShowNotification {
                bottmContainerView.constant = heightKeyboard
                UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                    self.view.layoutIfNeeded()
                })
            }
            else if notification.name == UIResponder.keyboardWillHideNotification {
                bottmContainerView.constant = 0
                UIView.animate(withDuration: TimeInterval(duration)) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

extension CAlertViewController: UITextViewDelegate {
    
}
