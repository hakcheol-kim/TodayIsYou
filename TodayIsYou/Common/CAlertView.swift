//
//  CAlertView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/23.
//

import UIKit
let TAG_ALERT_VIEW = 9876

class CAlertView: UIView {
    @IBOutlet weak var btnFullClose: UIButton!
    @IBOutlet weak var shadowBgView: CView!
    @IBOutlet weak var bgView: CView!
    @IBOutlet weak var svContainerView: UIStackView!
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var titleBgView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var svMessage: UIStackView!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var bgButtons: UIView!
    @IBOutlet weak var svButton: UIStackView!
    
    var customView: UIView?
    var customContentView: UIView?
    var title: String?
    var message: Any?
    var actions = [CAletActionType]()
    var btnTitles: [Any]?
    var btnTypes: [CAletActionType]?
    
    var completion: ((_ index: Int) ->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    private func commonInit() {
        let xib = Bundle.main.loadNibNamed("CAlertView", owner: self, options: nil)?.first as! UIView
        self.addSubview(xib)
        xib.addConstraintsSuperView()
        btnFullClose.isUserInteractionEnabled = false
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        lbTitle.text = ""
        lbMessage.text = ""
    }
    deinit {
        self.completion = nil
    }
    
    class func showWithCustomButton(title: String?, message: Any?, btnTitles: [Any]? = nil, btnTypes: [CAletActionType]? = nil, _ completion:((_ index: Int) ->Void)?) {
        let alert = CAlertView()
        alert.title = title
        alert.message = message
        alert.completion = completion
        alert.btnTitles = btnTitles
        alert.btnTypes = btnTypes
        alert.show()
    }
    class func showWithOk(title: String?, message: Any?, _ completion:((_ index: Int) ->Void)?) {
        let alert = CAlertView()
        alert.title = title
        alert.message = message
        alert.completion = completion
        alert.actions = [.ok]
        alert.show()
    }
    class func showWithCanCelOk(title: String?, message: Any?, _ completion:((_ index: Int) ->Void)?) {
        let alert = CAlertView()
        alert.title = title
        alert.message = message
        alert.completion = completion
        alert.actions = [.cancel, .ok]
        alert.show()
    }
    class func showCustomView(_ customView: UIView, _ actionComponets:[UIButton], _ completion:((_ index: Int) ->Void)?) {
        let alert = CAlertView()
        alert.customView = customView
        alert.completion = completion
        alert.show()
        var index = 0
        actionComponets.forEach { btn in
            btn.tag = 100 + index
            btn.addTarget(alert, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
            index += 1
        }
        appDelegate.window?.bringSubviewToFront(alert)
    }
    class func showCustomContentView(_ contentView: UIView, btnTitles:[Any], _ completion:((_ index: Int) ->Void)?) {
        let alert = CAlertView()
        alert.customContentView = contentView
        alert.btnTitles = btnTitles
        alert.show()
    }
    private func createButton(_ action:CAletActionType, _ title:Any? = nil) ->UIButton {
        let btn = UIButton(type: .custom)
        if action == .cancel {
            btn.setTitle(NSLocalizedString("activity_txt273", comment: "  Cancel"), for: .normal)
            btn.setTitleColor(.appColor(.gray102), for: .normal)
        }
        else if action == .ok {
            btn.setTitle(NSLocalizedString("activity_txt272", comment: "  Ok"), for: .normal)
            btn.setTitleColor(.appColor(.appColor), for: .normal)
        }
        else if let title = title as? String {
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.appColor(.blackText), for: .normal)
        }
        else if let title = title as? NSAttributedString {
            btn.setAttributedTitle(title, for: .normal)
        }
        btn.backgroundColor = .appColor(.whiteBg)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return btn
    }
    
    private func configurationUI() {
        if let customView = customView {
            svContainerView.subviews.forEach { subView in
                subView.removeFromSuperview()
            }
            svContainerView.addArrangedSubview(customView)
        }
        else {
            if let customContentView = customContentView {
                self.svContent.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                self.svContent.addArrangedSubview(customContentView)
            }
            else {
                titleBgView.isHidden = true
                if let title = title {
                    titleBgView.isHidden = false
                    lbTitle.text = title
                }
                
                svMessage.isHidden = true
                if let message = message as? String {
                    svMessage.isHidden = false
                    lbMessage.text = message
                }
                else if let message = message as? NSAttributedString {
                    svMessage.isHidden = false
                    lbMessage.attributedText = message
                }
            }
            
            //buttons make
            bgButtons.isHidden = true
            if let btnTitles = btnTitles {
                bgButtons.isHidden = false
                
                var index = 100
                btnTitles.forEach { title in
                    var type: CAletActionType = .normal
                    if let btnTypes = btnTypes, btnTypes.count <=  btnTitles.count {
                        type = btnTypes[index-100]
                    }
                    let btn = self.createButton(type, title)
                    btn.tag = index
                    svButton.addArrangedSubview(btn)
                    btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
                    index += 1
                }
            }
            else if actions.isEmpty == false {
                bgButtons.isHidden = false
                var index = 100
                actions.forEach { action in
                    let btn = self.createButton(action)
                    btn.tag = index
                    svButton.addArrangedSubview(btn)
                    btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
                    index += 1
                }
            }
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag >= 100 {
            self.completion?(sender.tag - 100)
            self.close()
        }
        else if sender == btnFullClose {
            self.close()
        }
    }
    private func show() {
        guard let window = appDelegate.window else {
            return
        }
        if let oldAlert = window.viewWithTag(TAG_ALERT_VIEW) {
            oldAlert.removeFromSuperview()
        }
        
        window.addSubview(self)
        self.frame = window.bounds
        
        self.configurationUI()
        self.alpha = 0
        shadowBgView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.shadowBgView.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { finish in
            
        }
    }
    
    private func close() {
        UIView.animate(withDuration: 0.01, delay: 0, options: .curveEaseOut) {
            self.alpha = 0
            self.shadowBgView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { finish in
            self.completion = nil
            self.removeFromSuperview()
        }
    }
}
