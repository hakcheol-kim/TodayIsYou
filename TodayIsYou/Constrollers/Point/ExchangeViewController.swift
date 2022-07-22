//
//  ExchangeViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON
import PanModal
class ExchangeViewController: BaseViewController {
   @IBOutlet weak var lbStarNotiMsg: UILabel!
   @IBOutlet weak var btnOk: UIButton!
   @IBOutlet weak var safetyView: UIView!
   @IBOutlet weak var tfMoney: CTextField!
   @IBOutlet weak var lbHintMoney: UILabel!
   @IBOutlet weak var btnBank: UIButton!
   
   @IBOutlet weak var lbHintBank: UILabel!
   @IBOutlet weak var tfAccountNum: CTextField!
   @IBOutlet weak var lbHintAccountNum: UILabel!
   
   @IBOutlet weak var tfHolderName: CTextField!
   @IBOutlet weak var lbHintHolderName: UILabel!
   @IBOutlet weak var tfIdentityNum1: CTextField!
   @IBOutlet weak var lbHintIdentifier: UILabel!
   @IBOutlet weak var tfIdentityNum2: CTextField!
   @IBOutlet weak var tfAddress: CTextField!
   @IBOutlet weak var lbHintAddress: UILabel!
   @IBOutlet weak var tvTerm: CTextView!
   @IBOutlet weak var heightTvTerm: NSLayoutConstraint!
   @IBOutlet weak var lbRPointMsg: UILabel!
   @IBOutlet weak var btnCheck: UIButton!
   @IBOutlet weak var tfBank: UITextField!
   
   var selBankName:String!
   
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
   var rPoint:NSNumber = NSNumber(integerLiteral: 0)
   
   override func viewDidLoad() {
      super.viewDidLoad()
      CNavigationBar.drawBackButton(self,  NSLocalizedString("activity_txt358", comment: "별 환급 신청"), #selector(actionNaviBack))
      arrTf = [tfMoney, tfAccountNum, tfHolderName, tfIdentityNum1, tfIdentityNum2, tfAddress]
      
      for tf in arrTf {
         tf.inputAccessoryView = toobar
         tf.delegate = self
      }
      btnCheck.titleLabel?.numberOfLines = 0
      self.addTapGestureKeyBoardDown()
      toobar.addTarget(self, selctor: #selector(onClickedToolbarActions(_:)))
      requestTerm()
      
      if let rp = ShareData.ins.dfsGet(DfsKey.userR) as? NSNumber {
         rPoint = rp
         let strPoint = rPoint.stringValue.addComma()
         lbRPointMsg.text = NSLocalizedString("activity_txt36", comment: "환급 신청금액 : ") + NSLocalizedString("activity_txt37", comment: "") + strPoint + NSLocalizedString("activity_txt38", comment: "")
         tfMoney.text = rPoint.stringValue.addComma()
      }
      safetyView.isHidden = !Utility.isEdgePhone()
      requestGetRPoint()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.addKeyboardNotification()
   }
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      self.removeKeyboardNotification()
   }
   func requestGetRPoint() {
      ApiManager.ins.requestGetRPoint(param: ["user_id":ShareData.ins.myId]) { res in
         let isSuccess = res["isSuccess"].stringValue
         if isSuccess == "01" {
            self.rPoint = res["user_r"].numberValue
            self.tfMoney.text = self.rPoint.stringValue
         }
         else {
            self.showErrorToast(res)
         }
      } failure: { error in
         self.showErrorToast(error)
      }
      
   }
   func requestTerm() {
      ApiManager.ins.requestServiceTerms(mode: "yk3") { (response) in
         self.yk = response["yk"].stringValue
         if self.yk.isEmpty == false {
            self.decorationUI()
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
//      paragraph.paragraphSpacing = 5
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
      if sender == btnBank {
         //         guard let banklist = ShareData.ins.getBankList() else {
         //            return
         //         }
         var banks = [String]()
         for i in 0..<38 {
            let key = "bank_\(i)"
            banks.append(NSLocalizedString(key, comment: ""))
         }
         let vc = PopupListViewController.initWithType(.normal, NSLocalizedString("bank_select", comment: "은행을 선택해주세요."), banks, nil) { vcs, selItem, index in
            vcs.dismiss(animated: true, completion: nil)
            guard let selItem = selItem as? String else {
               return
            }
            self.selBankName = Bank.severKey(selItem)
            self.tfBank.text = selItem
         }
         self.presentPanModal(vc)
         
      }
      else if sender == btnCheck {
         sender.isSelected = !sender.isSelected
      }
      else if sender == btnOk {
         lbHintMoney.text = NSLocalizedString("exchange_star_msg2", comment: "환급가능 별 개수를 입력해주세요.")
         lbHintMoney.isHidden = true
         lbHintBank.isHidden = true
         lbHintAccountNum.isHidden = true
         lbHintIdentifier.text = NSLocalizedString("exchange_msg", comment: "* 주민번호 및 주소는 세금 신고시에만 사용됩니다.")
         lbHintIdentifier.textColor = RGB(125, 125, 125)
         lbHintHolderName.isHidden = true
         
         guard let text = tfMoney.text, text.isEmpty == false else {
            lbHintMoney.isHidden = false
            return
         }
         let point:Int = Int(text.getNumberString()!) ?? 0
         if point > rPoint.intValue {
            lbHintMoney.text = NSLocalizedString("exchange_hint1", comment: "보유한 별 개수보다 적게 입력해주세요.")
            lbHintMoney.isHidden = false
            return
         }
         else if point < 20000 {
            lbHintMoney.isHidden = false
            return
         }
         
         guard let bankName = tfBank.text, bankName.isEmpty == false else {
            lbHintBank.isHidden = false
            return
         }
         guard let accountNumer = tfAccountNum.text, accountNumer.isEmpty == false else {
            lbHintAccountNum.isHidden = false
            return
         }
         guard let holderName = tfHolderName.text, holderName.isEmpty == false else {
            lbHintHolderName.isHidden = false
            return
         }
         guard let id1 = tfIdentityNum1.text, id1.isEmpty == false else {
            lbHintIdentifier.text = NSLocalizedString("exchange_hint2", comment: "주민번호 앞자리를 입력해주세요.")
            lbHintIdentifier.textColor = .red
            return
         }
         guard let id2 = tfIdentityNum1.text, id2.isEmpty == false else {
            lbHintIdentifier.text = NSLocalizedString("exchange_hint3", comment: "주민번호 뒷자리를 입력해주세요.")
            lbHintIdentifier.textColor = .red
            return
         }
         guard btnCheck.isSelected == true else {
            self.showToast(NSLocalizedString("login_term_msg", comment: "약관을 확인해주세요."))
            return
         }
         
         var param = [String:Any]()
         
         param["user_id"] = ShareData.ins.myId
         param["bank"] = bankName
         param["bank_num"] = accountNumer
         param["out_point"] = point
         param["jumin1"] = id1
         param["jumin2"] = id2
         param["bank_name"] = holderName
         param["user_addr"] = ""
         if let user_addr = tfAddress.text {
            param["user_addr"] = user_addr
         }
         
         ApiManager.ins.requestExchangeCoinToMoney(param: param) { res in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
               self.showToastWindow(NSLocalizedString("exchange_hint4", comment: "환급 신청이 완료되었습니다."))
               self.navigationController?.popViewController(animated: true)
            }
            else {
               self.showErrorToast(res)
            }
         } failure: { error in
            self.showErrorToast(error)
         }
         
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
