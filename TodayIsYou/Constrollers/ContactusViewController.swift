//
//  ContactusViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON
class ContactusViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var heightTextView: NSLayoutConstraint!
    @IBOutlet weak var btnWrite: UIButton!
    @IBOutlet weak var tvMsg: CTextView!
    
    var listData:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "고객센터 문의", #selector(actionNaviBack))
        self.addTapGestureKeyBoardDown()
        
        requestQnaList()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    func reloadTableView() {
        tblView.reloadData {
            if self.tblView.contentSize.height > self.tblView.bounds.size.height {
                self.tblView.contentOffset = CGPoint(x: 0, y: self.tblView.contentSize.height - self.tblView.frame.size.height)
            }
        }
    }
    func requestQnaList() {
        ApiManager.ins.requestQnaList(param: ["user_id":ShareData.ins.userId]) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            let result =  response["result"].arrayValue
            if isSuccess == "01" {
                if result.count > 0 {
                    self.listData = result
                    self.tblView.isHidden = false
                    self.reloadTableView()
                }
                else {
                    self.tblView.isHidden = true
                }
            }
            else {
                self.tblView.isHidden = true
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if (sender == btnWrite) {
            guard let msg = tvMsg.text, msg.isEmpty == false else {
                return
            }
            
            let param = ["question": msg, "user_id": ShareData.ins.userId]
            ApiManager.ins.requestQnaWrite(param:param) { (response) in
                let isSuccess = response["isSuccess"].stringValue
                if isSuccess == "01" {
                    self.requestQnaList()
                    self.tvMsg.text = nil
                    self.textViewDidChange(self.tvMsg)
                }
                else {
                    self.showErrorToast(response)
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
    }
}

extension ContactusViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ContactusCell") as? ContactusCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("ContactusCell", owner: nil, options: nil)?.first as? ContactusCell
        }
        cell?.configurationData(listData[indexPath.row])
        return cell!
    }
}

extension ContactusViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("text: \(text)")
        if text == "\n" {
            var height = textView.sizeThatFits(CGSize.init(width: textView.bounds.width - textView.contentInset.left - textView.contentInset.right, height: CGFloat.infinity)).height
            height = height + textView.contentInset.top + textView.contentInset.bottom
            heightTextView.constant = height
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
        
        var height = textView.sizeThatFits(CGSize.init(width: textView.bounds.width - textView.contentInset.left - textView.contentInset.right, height: CGFloat.infinity)).height
        height = height + textView.contentInset.top + textView.contentInset.bottom
        heightTextView.constant = height
    }
}
