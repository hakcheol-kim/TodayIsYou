//
//  ExchangeViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON

class ExchangeViewController: BaseViewController {
   @IBOutlet weak var btnOk: UIButton!
   @IBOutlet weak var safetyView: UIView!
   @IBOutlet weak var tfMoney: CTextField!
   @IBOutlet weak var btnBank: UIButton!
   @IBOutlet weak var tfAccountNum: CTextField!
   @IBOutlet weak var tfHolderName: CTextField!
   @IBOutlet weak var tfIdentityNum1: CTextField!
   @IBOutlet weak var tfIdentityNum2: CTextField!
   @IBOutlet weak var tfAddress: CTextField!
   @IBOutlet weak var tvTerm: CTextView!
   @IBOutlet weak var heightTvTerm: NSLayoutConstraint!
   
   let toobar = CToolbar.init(barItems: [.up, .down, .keyboardDown])
   var arrTf:[CTextField]!
   var yk: String!
   var tfFocus:CTextField! {
      didSet {
         let index:Int = arrTf.firstIndex(of: tfFocus)!
         if index == 0 {
            toobar.btnUp?.isEnabled = false
         }
         else if index == (arrTf.count-1) {
            toobar.btnDown?.isEnabled = false
         }
         else {
            toobar.btnUp?.isEnabled = true
            toobar.btnDown?.isEnabled = true
         }
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      CNavigationBar.drawBackButton(self, "별 환급 신청", #selector(actionNaviBack))
      arrTf = [tfMoney, tfAccountNum, tfHolderName, tfIdentityNum1, tfIdentityNum2, tfAddress]
      
      for tf in arrTf {
         tf.inputAccessoryView = toobar
         tf.delegate = self
      }
      
      self.addTapGestureKeyBoardDown()
      toobar.addTarget(self, selctor: #selector(onClickedToolbarActions(_:)))
      requestTerm()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.addKeyboardNotification()
   }
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      self.removeKeyboardNotification()
   }
   
   func requestTerm() {
      ApiManager.ins.requestServiceTerms(mode: "yk3") { (response) in
         let isSuccess = response["isSuccess"].stringValue
         if (isSuccess == "01") {
            self.yk = response["yk"].stringValue
            self.decorationUI()
         }
         else {
            self.showErrorToast(response)
         }
      } failure: { (error) in
         self.showErrorToast(error)
      }
   }
   func decorationUI() {
      let newYk = yk.replacingOccurrences(of: "\r\n\r\n", with: "\n")
      let attr = NSMutableAttributedString(string: newYk)
      attr.addAttribute(.font, value: UIFont.systemFont(ofSize: tvTerm.font?.pointSize ?? 14), range: NSMakeRange(0, attr.string.length))
      
      let paragraph = NSMutableParagraphStyle.init()
      paragraph.headIndent = 10
      paragraph.paragraphSpacing = 5
      attr.addAttribute(.paragraphStyle, value: paragraph, range: NSMakeRange(0, attr.string.length))
      tvTerm.attributedText = attr
      let height = tvTerm.sizeThatFits(CGSize(width: tvTerm.contentSize.width, height: CGFloat.greatestFiniteMagnitude)).height
      heightTvTerm.constant = height + tvTerm.contentInset.top + tvTerm.contentInset.bottom
      
   }
   @objc func onClickedToolbarActions(_ sender: UIBarButtonItem) {
      if sender.tag == TAG_TOOL_BAR_UP {
         let index:Int = arrTf.firstIndex(of: tfFocus)!
         if (index > 0) {
            let tf = arrTf[(index-1)]
            tf.becomeFirstResponder()
         }
      }
      else if sender.tag == TAG_TOOL_BAR_DOWN {
         let index:Int = arrTf.firstIndex(of: tfFocus)!
         if (index < arrTf.count) {
            let tf = arrTf[(index+1)]
            tf.becomeFirstResponder()
         }
      }
      else if sender.tag == TAG_TOOL_KEYBOARD_DOWN {
         self.view.endEditing(true)
      }
   }
   @IBAction func onClickedBtnActions(_ sender: UIButton) {
      if sender == btnOk {
         
      }
   }
}

extension ExchangeViewController: UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
      if let textField = textField as? CTextField  {
         self.tfFocus = textField
         textField.borderColor = RGB(230, 100, 100)
      }
   }
   func textFieldDidEndEditing(_ textField: UITextField) {
      if let textField = textField as? CTextField  {
         textField.borderColor = RGB(216, 216, 216)
      }
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if let textField = textField as? CTextField  {
         let index:Int = arrTf.firstIndex(of: textField)!
         if (index+1) < arrTf.count {
            let tfNext = arrTf[(index+1)]
            tfNext.becomeFirstResponder()
         }
         else {
            self.view.endEditing(true)
         }
      }
      return true
   }
}
