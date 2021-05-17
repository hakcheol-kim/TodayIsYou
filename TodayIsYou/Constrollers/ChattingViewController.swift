//
//  ChattingViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/07.
//

import UIKit
import SwiftyJSON
import BSImagePicker
import Photos

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
    @IBOutlet weak var btnGift: UIButton!
    
    var passData:JSON!
    var listData:[Any] = []
    var outChatPoint:NSNumber = 0
    
    var toUserId:String!
    var pointUserId:String!
    var toUserName: String!
    var messageKey:String!
    
    let df = CDateFormatter()
    var heightKeyboard:CGFloat = 0
    var isShowKeyboard = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        df.locale = Locale(identifier: "ko_KR")
        self.toUserName = passData["user_name"].stringValue
        self.toUserId = passData["user_id"].stringValue
        self.pointUserId = passData["point_user_id"].stringValue
        self.outChatPoint = passData["user_bbs_point"].numberValue
        self.messageKey = passData["seq"].stringValue
        
        CNavigationBar.drawBackButton(self, toUserName, #selector(actionNaviBack))
        CNavigationBar.drawRight(self, nil, "차단", 2000, #selector(onClickedBtnActions(_:)))
        CNavigationBar.drawRight(self, nil, "삭제", 2001, #selector(onClickedBtnActions(_:)))
        CNavigationBar.drawRight(self, nil, "영상", 2002, #selector(onClickedBtnActions(_:)))
        
        btnGift.isHidden = true
        if "남" == ShareData.ins.mySex.rawValue  {
            btnGift.isHidden = false
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapHandler(_ :)))
        self.view.addGestureRecognizer(tap)
        
        self.view.layoutIfNeeded()
      
        
        let lbHeader = UILabel.init(frame: CGRect(x: 0, y: 0, width: tblView.bounds.width, height: 20))
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
        self.resetKeyboadDown()
        self.updateDBReadMessage()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(PUSH_DATA), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(PUSH_DATA), object: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = tblView.tableHeaderView else {
            return
        }
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: tblView.bounds.width, height: 30)
    }
    func updateDBReadMessage() {
        DBManager.ins.updateReadMessage(messageKey: messageKey!, nil)
    }
    func relaodUi() {
        if self.isMyBlock {
            CNavigationBar.drawRight(self, nil, "차단해제", 2000, #selector(self.onClickedBtnActions(_:)))
            svEdtingMsg.isHidden = true
            lbBlockStateMsg.isHidden = false
        }
        else {
            CNavigationBar.drawRight(self, nil, "차단", 2000, #selector(self.onClickedBtnActions(_:)))
            svEdtingMsg.isHidden = false
            lbBlockStateMsg.isHidden = true
        }
    }
    func resetKeyboadDown() {
        self.view.endEditing(true)
        heightKeyboard = heightKeyboardAccoryview.constant
        self.aniKeyboardAccoryView(false, duration: 0.25)
    }
    private func requestChartMsgList() {
        let seq = passData["seq"].numberValue
        let param = ["message_key":seq]

        ApiManager.ins.requestChatMsgList(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            let message_key = res["message_key"].stringValue
            if isSuccess == "01", message_key.isEmpty == false {
                self.messageKey = message_key
            }
            self.getChatMessageFromDB()
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
    func makeGroupingGapOneDay(_ list:[ChatMessage]) {
        
        var arrSec:NSMutableArray!
        var preDate:Date? = nil
        
        listData.removeAll()
        
        for item in list {
            let curDate = item.reg_date
            if curDate == nil {
                continue
            }
            if preDate == nil || (preDate != nil && curDate != nil && ((curDate! - preDate!).day ?? 0) > 1) {
                let tmpDic = NSMutableDictionary()
                listData.append(tmpDic)
                
                df.dateFormat = "yyyy년 MM월 dd일 eeee"
                tmpDic["sec_title"] = df.string(from: curDate!)
                arrSec = NSMutableArray()
                tmpDic["sec_list"] = arrSec
                arrSec.add(item)
            }
            else {
                arrSec.add(item)
            }
            preDate = curDate
        }
    }
    func getChatMessageFromDB() {
        DBManager.ins.getChatMessage(messageKey: messageKey, { (result, error) in
            if let result = result, result.isEmpty == false {
                self.makeGroupingGapOneDay(result)
            }
            else {
                self.listData.removeAll()
            }
            self.reloadData()
        })
    }
    func reloadData() {
        self.tblView.reloadData {
            self.scrollToBottom()
        }
    }
    func scrollToBottom() {
        if listData.count > 0 {
            guard let tmpDic = listData.last as?[String:Any], let arrSec = tmpDic["sec_list"] as? [ChatMessage] else {
                return
            }
            let indexpath = IndexPath(row: arrSec.count-1, section: listData.count-1)
            self.tblView.scrollToRow(at: indexpath, at: .bottom, animated: false)
        }
        else {
            let  offsetY = self.tblView.contentSize.height - self.tblView.bounds.height
            if offsetY > 0 {
                self.tblView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
            }
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
            self.view.endEditing(true)
            btnMore.isSelected = false
            if isShowKeyboard == false {
                self.aniKeyboardAccoryView(false, duration: 0.25)
            }
        }
    }
    func requestDeleteChatMsg() {
        let param = ["seq":messageKey!, "to_user_id":toUserId!]
        ApiManager.ins.requestDeleteChatMessage(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                DBManager.ins.deleteChatMessage(messageKey: self.messageKey, nil)
                self.navigationController?.popViewController(animated: true)
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }

    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == 2000 {
            print("차단")
            self.resetKeyboadDown()
            if isMyBlock {
                self.requseDeleteBlockList()
            }
            else {
                self.requestSetBlockList()
            }
        }
        else if sender.tag == 2001 {
            print("삭제")
            self.resetKeyboadDown()
            CAlertViewController.show(type: .alert, title: "대화 삭제", message: "모든 대화가 삭제됩니다.", actions: [.cancel, .ok]) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                if index == 1 {
                    self.requestDeleteChatMsg()
                }
            }
        }
        else if sender.tag == 2002 {
            print("영상")
            self.resetKeyboadDown()
            self.selUser = passData
            self.checkCamTalk()
        }
        else if sender == btnGift {
            self.resetKeyboadDown()
            print("선물")
            var myPoint = ShareData.ins.myPoint?.intValue ?? 0
            let strMyPoint = "\(myPoint)".addComma()+"P"
            let tmpStr = "보유 : \(strMyPoint)"
            let title = "\(toUserName!)님에게 선물하기\n\(tmpStr)"
            let paragraphic = NSMutableParagraphStyle.init()
            paragraphic.lineSpacing = 5
            let attr = NSMutableAttributedString.init(string: title)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: NSMakeRange(0, title.length))
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .medium), range: (title as NSString).range(of: tmpStr))
            attr.addAttribute(.foregroundColor, value: RGB(230, 100, 100), range: (title as NSString).range(of: tmpStr))
            attr.addAttribute(.paragraphStyle, value: paragraphic, range: NSMakeRange(0, title.length))
            
            let data:[String] = ["100별(P)", "500별(P)", "1,000별(P)", "3,000별(P)", "5,000별(P)", "10,000별(P)"]
            let vc = PopupCollectionListViewController.initWithType(.gift, attr, data, nil) { (vcs, item, index) in
                vcs.dismiss(animated: true, completion: nil)
                var giftPoint = 0
                if index == 0 {
                    giftPoint = 100
                }
                else if index == 1 {
                    giftPoint = 500
                }
                else if index == 2 {
                    giftPoint = 1000
                }
                else if index == 3 {
                    giftPoint = 3000
                }
                else if index == 4 {
                    giftPoint = 5000
                }
                else if index == 5 {
                    giftPoint = 10000
                }
                
                if giftPoint > myPoint {
                    CAlertViewController.show(type: .alert, title: "포인트 부족", message: "보유한 포인트가 부족합니다. 포인트를 충전하시겠습니까?", actions: [.cancel, .ok]) { (vcs, selItem, index) in
                        vcs.dismiss(animated: true, completion: nil)
                        if index == 1 {
                            let vc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    return
                }
                else {
                    var param:[String:Any] = [:]
                    param["to_user_id"] = ShareData.ins.myId
                    param["user_id"] = self.toUserId!
                    param["seq"] = self.passData["seq"]
                    param["gift_point_str"] = giftPoint
                    param["gift_comment_write_str"] = ""
                    
                    ApiManager.ins.requestSendGiftPoint(param:param) { (res) in
                        let isSuccess = res["isSuccess"].stringValue
                        if isSuccess == "01" {
                            let msg = "\(giftPoint)".addComma()+" 별(P)를 선물했습니다."
                            self.showToast(msg)
                            
                            param["reg_date"] = Date()
                            param["read_yn"] = true
                            param["to_user_name"] = self.toUserName!
                            param["from_user_name"] = ""
                            param["memo"] = "🎁 \(msg)"
                            param["type"] = 1
                            param["message_key"] = self.messageKey
                            DBManager.ins.insertChatMessage(param) { (success, error) in
                                if success {
                                    self.getChatMessageFromDB()
                                }
                            }
                        }
                        else {
                            self.showErrorToast(res)
                        }
                    } fail: { (error) in
                        self.showErrorToast(error)
                    }
                }
            }
            self.presentPanModal(vc)
            
        }
        else if sender == btnAlbum {
            let imagePicker = ImagePickerController()
            imagePicker.settings.selection.max = 1
            imagePicker.settings.theme.selectionStyle = .checked
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
            imagePicker.settings.selection.unselectOnReachingMax = true
            
            self.presentImagePicker(imagePicker, animated: true) { (asset) in
                
            } deselect: { (asset) in
                
            } cancel: { (assets) in
                imagePicker.dismiss(animated: false)
            } finish: { (assets)  in
                imagePicker.dismiss(animated: false)
                guard let asset = assets.first else {
                    return
                }
               
                Utility.getThumnailImage(with: asset) { (image) in
                    guard let image = image else {
                        return
                    }
                    
                    var param:[String:Any] = [:]
                    param["message_key"] = self.messageKey
                    param["type"] = 1
                    param["from_user_id"] = ShareData.ins.myId
                    param["to_user_id"] = self.toUserId!
                    param["point_user_id"] = self.passData["point_user_id"].stringValue
                    param["out_chat_point"] = self.passData["out_chat_point"].stringValue
                    param["user_file"] = image
                    param["memo"] = "FILE 전송"
                    
                    self.requestSendMessage(param)
                }
            } completion: {
                
            }
        }
        else if sender == btnCamera {
            //시뮬레이터일때 죽는것 방지
            guard UIImagePickerController.isSourceTypeAvailable(.camera) == true else {
                let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Alright", style: .default, handler: { (alert: UIAlertAction!) in
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let picker = CImagePickerController.init() { (origin, crop) in
                guard let crop = crop else {
                    return
                }
                var param:[String:Any] = [:]
                param["message_key"] = self.messageKey
                param["type"] = 1
                param["from_user_id"] = ShareData.ins.myId
                param["to_user_id"] = self.toUserId!
                param["point_user_id"] = self.passData["point_user_id"].stringValue
                param["out_chat_point"] = self.passData["out_chat_point"].stringValue
                param["user_file"] = crop
                param["memo"] = "FILE 전송"
                
                self.requestSendMessage(param)
            }
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
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
            if sender.isSelected && isShowKeyboard == false {
                self.aniKeyboardAccoryView(true, duration: 0.25)
            }
            else if sender.isSelected && isShowKeyboard == true {
                self.view.endEditing(true)
                self.aniKeyboardAccoryView(true, duration: 0.25)
            }
            else if sender.isSelected == false && isShowKeyboard == false {
                tvChatting.becomeFirstResponder()
            }
            else {
                self.aniKeyboardAccoryView(false, duration: 0.25)
            }
        }
        else if sender == btnSend {
            guard let text = tvChatting.text, text.isEmpty == false else {
                self.showToast("메세지를 입력 하세요!!")
                return
            }
            var param:[String:Any] = [:]
            param["message_key"] = messageKey
            param["from_user_id"] = ShareData.ins.myId
            param["to_user_id"] = toUserId!
            param["point_user_id"] = passData["point_user_id"].stringValue
            param["out_chat_point"] = passData["out_chat_point"].stringValue
            param["memo"] = text
            
            self.requestSendMessage(param)
        }
    }
    
    func requestSendMessage(_ param:[String:Any]) {
        if self.isBlocked == true {
            self.showToast("상대가 차단했습니다!!")
            return
        }
        
        ApiManager.ins.requestSendChattingMsg(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                var data = param
                data["file_name"] = res["file_name"].stringValue
                data["reg_date"] = Date()
                data["read_yn"] = true
                data["to_user_name"] = self.toUserName!
                data["from_user_name"] = ""
                data["type"] = 1
                
                self.tvChatting.text = ""
                DBManager.ins.insertChatMessage(data) { (success, error) in
                    if success {
                        self.getChatMessageFromDB()
                    }
                }
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
    
    func aniKeyboardAccoryView(_ isShow:Bool, duration:CGFloat) {
        if toUserId! == "manager" {
            bottomSafeKeybardAccoryView.constant = -(keyboardAccoryView.bounds.height)
        }
        else if isShow {
            heightKeyboardAccoryview.constant = heightKeyboard
            let safeBottom:CGFloat = self.view.window?.safeAreaInsets.bottom ?? 0
            bottomSafeKeybardAccoryView.constant = -safeBottom
        }
        else {
            bottomSafeKeybardAccoryView.constant = -heightKeyboard
        }
        
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK:: notification handler
    override func notificationHandler(_ notification: NSNotification) {
        if notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillHideNotification {
            
            let height = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
            heightKeyboard = height
            print("keyboard height: \(height), duratin:\(duration)")
            if notification.name == UIResponder.keyboardWillShowNotification {
                isShowKeyboard = true
                self.aniKeyboardAccoryView(true, duration: duration)
                self.scrollToBottom()
            }
            else if notification.name == UIResponder.keyboardWillHideNotification {
                isShowKeyboard = false
            }
        }
        else if notification.name == Notification.Name(rawValue: PUSH_DATA) {
            guard let type = notification.object as? PushType, let userInfo = notification.userInfo as?[String:Any] else {
                return
            }
            
            let info = JSON(userInfo)
            if type == .chat {
                let message_key = info["message_key"].stringValue
                if self.messageKey == message_key {
                    self.updateDBReadMessage()
                    self.requestChartMsgList()
                }
            }
            else if type == .msgDel {
                self.showToastWindow("\(toUserName!)님이 대화방을 나갔습니다.")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tmpDic = listData[section] as? [String:Any],  let arrSec = tmpDic["sec_list"] as? [ChatMessage] {
            return arrSec.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        guard let tmpDic = listData[indexPath.section] as? [String:Any],  let arrSec = tmpDic["sec_list"] as? [ChatMessage] else {
            return UITableViewCell()
        }
        
        let chat = arrSec[indexPath.row]
        if chat.type == 0 {
            var tmpCell = tableView.dequeueReusableCell(withIdentifier: ChattingLeftCell.identifier) as? ChattingLeftCell
            if tmpCell == nil {
                tmpCell = Bundle.main.loadNibNamed(ChattingLeftCell.identifier, owner: nil, options: nil)?.first as? ChattingLeftCell
            }
            let profile_name = self.passData["talk_img"].stringValue
            tmpCell?.configurationData(chat, profile_name)
            
            tmpCell?.didClickedClosure = {(selItem, index) ->Void in
                if let selItem = selItem as? String, index == 1 {
                    self.showPhoto(imgUrls: [selItem])
                }
                else if index == 100 {
//                    let height = selItem as! CGFloat
//                    chat.height = Double(height)
                    self.tblView.beginUpdates()
                    self.tblView.endUpdates()
                }
                else if index == 101 || index == 102 {
                    self.resetKeyboadDown()
                    self.selUser = self.passData
                    self.checkCamTalk()
                }
            }
            cell = tmpCell
        }
        else {
            var tmpCell = tableView.dequeueReusableCell(withIdentifier: ChattingRightCell.identifier) as? ChattingRightCell
            if tmpCell == nil {
                tmpCell = Bundle.main.loadNibNamed(ChattingRightCell.identifier, owner: nil, options: nil)?.first as? ChattingRightCell
            }
            tmpCell?.configurationData(chat)
            
            tmpCell?.didClickedClosure = {(selItem, index) ->Void in
                if let selItem = selItem as? String, index == 1 {
                    self.showPhoto(imgUrls: [selItem])
                }
                else if index == 100 {
//                    let height = selItem as! CGFloat
//                    chat.height = Double(height)
                    
                    self.tblView.beginUpdates()
                    self.tblView.endUpdates()
                    
                }
            }
            cell = tmpCell
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tmpDic = listData[indexPath.section] as? [String:Any],  let arrSec = tmpDic["sec_list"] as? [ChatMessage] else {
            return UITableView.automaticDimension
        }
        
        let chat = arrSec[indexPath.row]
        if chat.height > 0 {
            return CGFloat(chat.height)
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tmpDic = listData[section] as? [String:Any], let secTitle = tmpDic["sec_title"] as? String else {
            return nil
        }
        
        let header = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 25))
        
        let btn = UIButton.init()
        header.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: 0).isActive = true
        btn.centerXAnchor.constraint(equalTo: header.centerXAnchor, constant: 0).isActive = true
        btn.topAnchor.constraint(equalTo: header.topAnchor, constant: 0).isActive = true
        btn.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: 0).isActive = true
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle(secTitle, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        btn.layer.cornerRadius = header.bounds.height/2
        btn.backgroundColor = RGBA(0, 0, 0, 0.3)
        
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
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
        self.btnMore.isSelected = false
    }
}
