//
//  ChattingViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/07.
//

import UIKit
import SwiftyJSON
class ChattingViewController: MainActionViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var keyboardAccoryView: UIView!
    @IBOutlet weak var tvChatting: CTextView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnAlbum: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnJim: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var svEdtingMsg: UIStackView!
    @IBOutlet weak var lbBlockStateMsg: Clabel!
    
    @IBOutlet weak var heightKeyboardAccoryview: NSLayoutConstraint!
    @IBOutlet weak var bottomSafeKeybardAccoryView: NSLayoutConstraint!
    @IBOutlet weak var heightTextView: NSLayoutConstraint!
    
    var passData:JSON!
    var listData:[JSON] = []
    var outChatPoint:NSNumber = 0
    
    var toUserId:String!
    var pointUserId:String!
    var toUserName: String!
    
    var isKeyboardDown:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toUserName = passData["user_name"].stringValue
        self.toUserId = passData["user_id"].stringValue
        self.pointUserId = passData["point_user_id"].stringValue
        self.outChatPoint = passData["user_bbs_point"].numberValue
        
        CNavigationBar.drawBackButton(self, toUserName, #selector(actionNaviBack))
        CNavigationBar.drawRight(self, nil, "차단", 1001, #selector(onClickedBtnActions(_:)))
        CNavigationBar.drawRight(self, nil, "삭제", 1002, #selector(onClickedBtnActions(_:)))
        CNavigationBar.drawRight(self, nil, "영상", 1003, #selector(onClickedBtnActions(_:)))
        if "남" == ShareData.ins.mySex.rawValue  {
            CNavigationBar.drawRight(self, nil, "선물", 1004, #selector(onClickedBtnActions(_:)))
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapHandler(_ :)))
        self.view.addGestureRecognizer(tap)
        bottomSafeKeybardAccoryView.constant = -210
        self.view.layoutIfNeeded()
        
        let lbHeader = UILabel.init()
        lbHeader.font = UIFont.systemFont(ofSize: 12)
        lbHeader.textColor = RGB(230, 100, 100)
        lbHeader.textAlignment = .center
        
        if pointUserId == ShareData.ins.myId {
            outChatPoint = 0
        }
        
        if outChatPoint.intValue > 0 {
            lbHeader.text = "\(outChatPoint.stringValue.addComma()) 포인트가 소모되는 유료 채팅입니다."
        }
        else {
            lbHeader.text = "포인트 소모가 없는 무료 채팅 입니다."
        }
        self.tblView.tableHeaderView = lbHeader
        
        self.requestChartMsgList()
        self.getMyBlockList(toUserId: toUserId)
        self.getBlackList(toUserId: toUserId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = tblView.tableHeaderView else {
            return
        }
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: tblView.bounds.width, height: 30)
    }
    
    func relaodUi() {
        if self.isMyBlock {
            CNavigationBar.drawRight(self, nil, "차단해제", 1001, #selector(self.onClickedBtnActions(_:)))
            svEdtingMsg.isHidden = true
            lbBlockStateMsg.isHidden = false
        }
        else {
            CNavigationBar.drawRight(self, nil, "차단", 1001, #selector(self.onClickedBtnActions(_:)))
            svEdtingMsg.isHidden = false
            lbBlockStateMsg.isHidden = true
        }
    }
    private func requestChartMsgList() {
        let seq = passData["seq"].numberValue
        let param = ["message_key":seq]

        ApiManager.ins.requestChatMsgList(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                
            }
            else {
                
            }
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
    
    //내가 차단한 리스트
    private func getMyBlockList(toUserId:String) {
        self.isMyBlock = false
        let prama = ["black_user_id":toUserId, "user_id": ShareData.ins.myId]
        ApiManager.ins.requestGetBlockList(param: prama) { (response) in
            if response["isSuccess"].stringValue == "01" {
                let black_list_cnt = response["black_list_cnt"].intValue
                if black_list_cnt > 0 {
                    self.isMyBlock = true
                }
            }
            self.relaodUi()
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    //상대방이 차단
    private func getBlackList(toUserId:String) {
        self.isBlocked = false
        let prama = ["black_user_id" : ShareData.ins.myId, "user_id" : toUserId]
        ApiManager.ins.requestGetBlockList(param: prama) { (response) in
            if response["isSuccess"].stringValue == "01" {
                let black_list_cnt = response["black_list_cnt"].intValue
                if black_list_cnt > 0 {
                    self.isBlocked = true
                    self.showToast("상대가 차단했습니다!!")
                }
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    func requseDeleteBlockList() {
        let param:[String:Any] = ["user_id":ShareData.ins.myId, "black_user_id": toUserId!]
        ApiManager.ins.requestDeleteBlockList(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.isMyBlock = false
                self.relaodUi()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
    func requestSetBlockList() {
        let param:[String:Any] = ["user_id":ShareData.ins.myId, "black_user_id": toUserId!]
        ApiManager.ins.requestSetBlockList(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.isMyBlock = true
                self.relaodUi()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
    func requestSetMyFriend() {
        let param:[String:Any] = ["my_id":ShareData.ins.myId, "user_id": toUserId!, "user_name":toUserName!]
        ApiManager.ins.requestSetMyFried(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.showToast("찜 등록 완료되었습니다.")
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
    //MARK:: custom button actions
    @objc func didTapHandler(_ gesture:UIGestureRecognizer) {
        if gesture.view == self.view {
            isKeyboardDown = true
            self.view.endEditing(true)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == 1001 {
            print("차단")
            self.view.endEditing(true)
            if isMyBlock {
                self.requseDeleteBlockList()
            }
            else {
                self.requestSetBlockList()
            }
        }
        else if sender.tag == 1002 {
            print("삭제")
            self.view.endEditing(true)
            CAlertViewController.show(type: .alert, title: "대화 삭제", message: "모든 대화가 삭제됩니다.", actions: [.cancel, .ok]) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                if index == 1 {
                    
                }
            }
        }
        else if sender.tag == 1003 {
            print("영상")
            self.view.endEditing(true)
            self.selUser = passData
            self.checkCamTalk()
        }
        else if sender.tag == 1004 {
            self.view.endEditing(true)
            print("선물")
        }
        else if sender == btnAlbum {
            
        }
        else if sender == btnCamera {
            
        }
        else if sender == btnJim {
            if toUserId == ShareData.ins.myId {
                self.showToast("본인입니다.")
                return
            }
            self.requestSetMyFriend()
        }
        else if sender == btnReport {
            self.selUser = passData
            self.actionBlockAlert()
        }
        else if sender == btnMore {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.view.endEditing(true)
            }
            else {
                tvChatting.becomeFirstResponder()
            }
        }
        else if sender == btnSend {
            
        }
    }

    //MARK:: notification handler
    override func notificationHandler(_ notification: NSNotification) {
        if notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillHideNotification {
            
            let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
            
            if notification.name == UIResponder.keyboardWillShowNotification {
                heightKeyboardAccoryview.constant = heightKeyboard
                let safeBottom:CGFloat = self.view.window?.safeAreaInsets.bottom ?? 0
                bottomSafeKeybardAccoryView.constant = -safeBottom
                UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                    self.view.layoutIfNeeded()
                })
            }
            else if notification.name == UIResponder.keyboardWillHideNotification {
                if isKeyboardDown == true {
                    isKeyboardDown = false
                    bottomSafeKeybardAccoryView.constant = -heightKeyboard
                    UIView.animate(withDuration: TimeInterval(duration)) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
        
    }
    
    //overide method 
    override func actionAlertPhoneCall() {
        
    }
    override func actionAlertCamTalkCall() {
        
    }
    override func actionBlockAlert() {
        let user_name = self.selUser["user_name"].stringValue
        let user_id = self.selUser["user_id"].stringValue
        
        let alert = CAlertViewController.init(type: .alert, title: "\(user_name)님 신고하기", message: nil, actions: [.cancel, .ok]) { (vcs, selItem, index) in
            
            if (index == 1) {
                guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                    return
                }
                vcs.dismiss(animated: true, completion: nil)
                let param = ["user_name":user_name, "to_user_id":user_id, "user_id":ShareData.ins.myId, "memo":text]
                ApiManager.ins.requestReport(param: param) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        self.showToast("신고가 완료되었습니다.")
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } failure: { (error) in
                    self.showErrorToast(error)
                }
            }
            else {
                vcs.dismiss(animated: true, completion: nil)
            }
        }
        alert.iconImg = UIImage(named: "warning")
        alert.addTextView("신고 내용을 입력해주세요.", UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChattingCell.identifier) as? ChattingCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ChattingViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        btnMore.isSelected = false
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        btnMore.isSelected = true
        return true
    }
}
