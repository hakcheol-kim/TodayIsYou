//
//  CAlertViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/19.
//

import UIKit
enum CAletType {
    case alert, custom
}

enum CAletActionType {
    case ok, cancel, normal, check
}

typealias CAletClosure = (_ vcs:CAlertViewController, _ selItem:Any?, _ index:Int) ->Void

class CAlertViewController: UIViewController {
    @IBOutlet weak var btnIcon: CButton!
    @IBOutlet weak var containerView: CView!
    @IBOutlet weak var svContainer: UIStackView!
    @IBOutlet weak var svTitle: UIStackView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var svButton: UIStackView!
    @IBOutlet weak var btnsView: UIView!
    @IBOutlet weak var bottmContainerView: NSLayoutConstraint!
    @IBOutlet weak var shadowView: CView!
    @IBOutlet weak var heightBtn: NSLayoutConstraint!
    @IBOutlet weak var btnFullClose: UIButton!
    
    var lbMsgTextAligment: NSTextAlignment = .center
    var isBackGroundTouchClose: Bool = true
    var fontMsg: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    var fontTitle: UIFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    
    var insetContent:UIEdgeInsets = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
    var insetTitle:UIEdgeInsets = UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16)
    
    var type: CAletType = .alert
    var aletTitle: Any?
    var message: Any?
    var completion: CAletClosure?
    
    var arrBtn:Array<UIButton> = []
    var arrTextView:[CTextView] = []
    var actions:[CAletActionType]?
    var iconImgName: String = ""
    var iconImg:UIImage?
    var customView: UIView?
    var arrBtnCheck:Array<UIButton> = []
    
     convenience init(type:CAletType, title:Any? = nil, message:Any? = nil, actions:[CAletActionType]?, completion:CAletClosure?) {
        self.init()
        self.type = type
        self.aletTitle = title
        self.message = message
        self.actions = actions
        self.completion = completion
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    class func show(type:CAletType, title:Any? = nil, message:Any? = nil, actions:[CAletActionType]?, completion:CAletClosure?) {
        let calert = CAlertViewController.init(type: type, title: title, message: message, actions: actions, completion: completion)
        UIApplication.shared.keyWindow?.rootViewController?.present(calert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 8
        containerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: true, BR: true)
        
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
        btnIcon.isHidden = true
        
        if titleView.isHidden == false {
            if iconImgName.isEmpty == false {
                svTitle.layoutMargins = UIEdgeInsets(top: 40, left: 16, bottom: 8, right: 8)
                lbTitle.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                btnIcon.imageView?.contentMode = .scaleAspectFill
                btnIcon.isHidden = false
                if iconImgName.contains("http") == true || iconImgName.contains("https") {
                    btnIcon.setImageCache(iconImgName)
                    btnIcon.accessibilityValue = iconImgName
                }
                else {
                    if let image = UIImage(named: iconImgName) {
                        btnIcon.setImage(image, for: .normal)
                    }
                }
            }
            else if let iconImg = iconImg {
                svTitle.layoutMargins = UIEdgeInsets(top: 40, left: 16, bottom: 8, right: 8)
                lbTitle.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                btnIcon.isHidden = false
                
                btnIcon.setImage(iconImg, for: .normal)
                btnIcon.contentVerticalAlignment = .fill
                btnIcon.contentHorizontalAlignment = .fill
                btnIcon.imageView?.contentMode = .scaleAspectFit
                btnIcon.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            }
            else {
                svTitle.layoutMargins = insetTitle
            }
        }
        
        
        if type == .custom {
            if let customView = customView {
                svContent.addArrangedSubview(customView)
                svContent.layoutMargins = UIEdgeInsets.zero
            }
        }
        else if type == .alert {
            if let message = message as? NSAttributedString {
                let lbMsg = self.createMsgLabel()
                svContent.addArrangedSubview(lbMsg)
                lbMsg.attributedText = message
            }
            else if let message = message as? String {
                let lbMsg = self.createMsgLabel()
                svContent.addArrangedSubview(lbMsg)
                lbMsg.text = message
            }
        }
        
        if let actions = actions {
            for subview in svButton.subviews {
                subview.removeFromSuperview()
            }
            arrBtn.removeAll()
            for action in actions {
                if (action == .ok) {
                    self.addAction(action, NSLocalizedString("activity_txt478", comment: "확인"))
                }
                else if (action == .cancel) {
                    self.addAction(action, NSLocalizedString("activity_txt479", comment: "취소"))
                }
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func createMsgLabel() -> UILabel {
        if let lb = svContent.viewWithTag(10005) as? UILabel {
            lb.removeFromSuperview()
        }
        let lbMsg = UILabel.init()
        lbMsg.tag = 10005
        lbMsg.textAlignment = lbMsgTextAligment
        lbMsg.textColor = UIColor.label
        lbMsg.font = fontMsg
        lbMsg.numberOfLines = 0
        return lbMsg
    }
    
    func addCustomView(_ view:UIView) {
        self.view.layoutIfNeeded()
        self.customView = view
        self.reloadUI()
    }
    
    func addAction(_ actionType:CAletActionType, _ title:String? = nil, _ img: UIImage? = nil, _ tintColor: UIColor? = UIColor.lightGray, _ isSelected:Bool = false) {
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
        
        if actionType == .ok
            || actionType == .cancel
            || actionType == .normal {
            
            btnsView.isHidden = false
            svButton.addArrangedSubview(btn)
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
            btn.tag = 100+arrBtn.count
            arrBtn.append(btn)
        }
        else if actionType == .check {
            var svCheckBtn: UIStackView!
            if let sv = svContent.viewWithTag(121212) as? UIStackView {
                svCheckBtn = sv
            }
            else {
                svCheckBtn = UIStackView.init()
                svCheckBtn.tag = 121212
                svCheckBtn.axis = .vertical
                svCheckBtn.spacing = 0
                svContent.insertArrangedSubview(svCheckBtn, at: 0)
                svContent.spacing = 16
            }
            arrBtnCheck.append(btn)
            btn.contentHorizontalAlignment = .leading
            btn.setImage(UIImage(systemName: "square"), for: .normal)
            btn.setImage(UIImage(systemName: "checkmark.square"), for: .selected);
            btn.tintColor = tintColor
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            svCheckBtn.addArrangedSubview(btn)
            btn.isSelected = isSelected
            btn.heightAnchor.constraint(equalToConstant: 35).isActive = true
            btn.tag = 200+svCheckBtn.subviews.count
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
    }
    
    func addTextView(_ placeholder: String? = nil, _ edge: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), _ height:CGFloat = 120) {
        self.view.layoutIfNeeded()
        
        var svWrap: UIStackView!
        if let sv = svContent.viewWithTag(12345) as? UIStackView {
            svWrap = sv
        }
        else {
            svWrap = UIStackView()
            svWrap.axis = .vertical
            svWrap.tag = 12345
            svWrap.spacing = 8
            
            svContent.addArrangedSubview(svWrap)
            svContent.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        let tv = CTextView.init()
        svWrap.addArrangedSubview(tv)
        
        if let placeholder = placeholder {
            tv.placeHolderString = placeholder
        }
        
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        let h = tv.heightAnchor.constraint(equalToConstant: height)
        h.priority = UILayoutPriority.init(999)
        h.isActive = true
        
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = RGB(216, 216, 216).cgColor
        tv.layer.cornerRadius = 8
        
        tv.insetLeft = edge.left
        tv.insetTop = edge.top
        tv.insetBottom = edge.bottom
        tv.insetRigth = edge.right
        
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
        else if sender.tag < 200 { //ok, cancel
            if arrBtnCheck.count > 0 || arrTextView.count > 0 {
                self.completion?(self, nil, sender.tag-100)
            }
            else {
                self.dismiss(animated: true, completion: nil)
                self.completion?(self, nil, sender.tag-100)
            }
        }
        else if sender.tag < 300 {
            sender.isSelected = !sender.isSelected
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
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }
}
