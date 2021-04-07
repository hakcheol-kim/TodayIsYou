//
//  TalkListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON

class TalkListViewController: MainActionViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnGender: CButton!
    @IBOutlet weak var btnArea: CButton!
    @IBOutlet weak var lbNotice: UILabel!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:String = ShareData.ins.userSex.transGender().rawValue
    var searchArea: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let footerview = UIView.init()
        footerview.backgroundColor = UIColor.systemGray6
        tblView.tableFooterView = footerview
        lbNotice.layer.cornerRadius = 4
        self.dataRest()
        tblView.cr.addHeadRefresh { [weak self] in
            self?.dataRest()
        }
        
        if let lbGender = btnGender.viewWithTag(100) as? UILabel {
            lbGender.text = searchSex
        }
        
        if let lbArea = btnArea.viewWithTag(100) as? UILabel {
            lbArea.text = "전체"
        }
    }
    
    func dataRest() {
        pageNum = 1
        pageEnd = false
        requestTalkList()
        if listData.count > 0 {
            self.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    func addData() {
        requestTalkList()
    }
    
    func requestTalkList() {
        if pageEnd == true {
            return
        }
        
        var param: [String:Any] = [:]
        param["app_type"] = appType
        param["user_id"] = ShareData.ins.userId
        param["pageNum"] = pageNum
        param["search_sex"] = searchSex
        param["search_area"] = searchArea
        
        ApiManager.ins.requestTalkList(param: param) { (resonse) in
            self.canRequest = true
            let result = resonse["result"].arrayValue
            let isSuccess = resonse["isSuccess"].stringValue
            if isSuccess == "01" {
                if result.count == 0 {
                    self.pageEnd = true
                }
                else {
                    if self.pageNum == 1 {
                        self.listData = result
                    }
                    else {
                        self.listData.append(contentsOf: result)
                    }
                }
                self.tblView.cr.endHeaderRefresh()
                if (self.listData.count > 0) {
                    self.tblView.isHidden = false
                    self.tblView.reloadData()
                }
                else {
                    self.tblView.isHidden = true
                }
                self.pageNum += 1
            }
            else {
                self.showErrorToast(resonse)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnGender {
            let vc = PopupListViewController.initWithType(.normal, "성별을 선택해주세요.", ["남", "여"], nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: false, completion: nil)
                
                guard let selItem = selItem as? String, let lbGender = self.btnGender.viewWithTag(100) as? UILabel else {
                    return
                }
                lbGender.text = selItem
                self.searchSex = selItem
                self.dataRest()
            }
            self.presentPanModal(vc)
        }
        else if sender == btnArea {
            guard var area = ShareData.ins.getArea() else {
                return
            }
            area.insert("전체", at: 0)
            let vc = PopupListViewController.initWithType(.normal, "지역을 선택해주세요.", area, nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                
                guard let selItem = selItem as? String, let lbArea = self.btnArea.viewWithTag(100) as? UILabel  else {
                    return
                }
                
                lbArea.text = selItem
                if selItem == "전체" {
                    self.searchArea = ""
                }
                else {
                    self.searchArea = selItem
                }
                self.dataRest()
            }
            self.presentPanModal(vc)
        }
    }
    
    override func presentTalkMsgAlert() {
        var msg:String? = nil
        if let bbsPoint = ShareData.ins.dfsObjectForKey(DfsKey.userBbsPoint) as? NSNumber, bbsPoint.intValue > 0 {
            msg = "메세지 전송시 \(bbsPoint)P 소모됩니다."
        }
    
        let alert = CAlertViewController.init(type: .alert, title: "메세지 전송", message: msg, actions: [.cancel, .ok]) { (vcs, selItem, index)  in
            
            if index == 1 {
                guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                    self.showToast("내용을 입력해주세요.")
                    return
                }
                self.requestSendMsg(text)
                vcs.dismiss(animated: true, completion: nil)
            }
            else {
                vcs.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.iconImg = UIImage(systemName: "envelope.fill")
        alert.addTextView("입력해주세요.")
        alert.reloadUI()
        self.present(alert, animated: true, completion: nil)
    }
    
    func requestSendMsg(_ content:String) {
        
        var param:[String:Any] = [:]
            
        var friend_mode = "N"
        if isMyFriend {
            friend_mode = "Y"
        }
        var bbsPoint = 0
        if let p = ShareData.ins.dfsObjectForKey(DfsKey.userBbsPoint) as? NSNumber {
            bbsPoint = p.intValue
        }
        param["user_id"] = ShareData.ins.userId
        param["from_user_id"] = ShareData.ins.userId
        param["from_user_sex"] = ShareData.ins.userSex.rawValue
        param["to_user_id"] = self.selectedUser["user_id"].stringValue
        param["to_user_name"] = self.selectedUser["user_name"].stringValue
        param["memo"] = content
        param["user_bbs_point"] = bbsPoint
        param["point_user_id"] = ShareData.ins.userId
        param["friend_mode"] = friend_mode
        
        ApiManager.ins.requestSendTalkMsg(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "00" {
                let errorCode = res["errorCode"].stringValue
                if errorCode == "0002" {
                    self.showToast("탈퇴한 회원 입니다")
                }
                else if errorCode == "0003" {
                    self.showToast("차단 상태인 회원 입니다")
                }
                else {
                    self.showToast("오류!!")
                }
            }
            else {
                self.showToast("쪽지 전송 완료");
                //TODO:: Save local db
                
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
}

extension TalkListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TalkTblCell") as? TalkTblCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("TalkTblCell", owner: nil, options: nil)?.first as? TalkTblCell
        }
        if indexPath.row < listData.count {
            let item = listData[indexPath.row]
            cell?.configurationData(item)
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedUser = listData[indexPath.row]
        self.checkAvaiableTalkMsg()
    }
}

extension TalkListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
            canRequest = false
            self.addData()
        }
    }
}
