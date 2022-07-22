//
//  ChattingListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
import CRRefresh

class ChattingListViewController: BaseViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnDelAll: UIButton!
    @IBOutlet weak var btnJim: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.ins.mySex.transGender()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let footerview = UIView.init()
        footerview.backgroundColor = UIColor.systemGray6
        tblView.tableFooterView = footerview
        tblView.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            self?.dataRest()
        }
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataRest()
        appDelegate.mainViewCtrl.updateUnReadMessageCount()
        self.requestGetPoint()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(PUSH_DATA), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(PUSH_DATA), object: nil)
    }
    func initUI() {
        let imgNor = UIImage.color(from: .appColor(.grayButtonBg))
        let imgSel = UIImage.color(from: .appColor(.appColor))
        
        btnDelAll.setBackgroundImage(imgNor, for: .normal)
        btnDelAll.setBackgroundImage(imgSel, for: .selected)
        btnDelAll.setTitleColor(.appColor(.gray125), for: .normal)
        btnDelAll.setTitleColor(.appColor(.whiteText), for: .selected)
        btnDelAll.adjustsImageWhenHighlighted = false
        
        btnJim.setBackgroundImage(imgNor, for: .normal)
        btnJim.setBackgroundImage(imgSel, for: .selected)
        btnJim.setTitleColor(.appColor(.gray125), for: .normal)
        btnJim.setTitleColor(.appColor(.whiteText), for: .selected)
        btnJim.adjustsImageWhenHighlighted = false
        
        btnBlock.setBackgroundImage(imgNor, for: .normal)
        btnBlock.setBackgroundImage(imgSel, for: .selected)
        btnBlock.setTitleColor(.appColor(.gray125), for: .normal)
        btnBlock.setTitleColor(.appColor(.whiteText), for: .selected)
        btnBlock.adjustsImageWhenHighlighted = false
        
        btnDelAll.isSelected = true
    }
    func dataRest() {
        pageNum = 1
        pageEnd = false
        requestMyMessageList()
        if listData.count > 0 {
            self.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    func addData() {
        requestMyMessageList()
    }
    func requestMyMessageList() {
        if pageEnd == true {
            return
        }
        
        var param:[String:Any] = [:]
        
        param["user_id"] = ShareData.ins.myId
        param["pageNum"] = pageNum
        ApiManager.ins.requestMsgList(param: param) { (response) in
            self.canRequest = true
            let result = response["result"].arrayValue
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                if self.pageNum == 1 {
                    self.listData = result
                }
                else if result.isEmpty == false {
                    self.listData.append(contentsOf: result)
                }
                
                if result.count == 0 {
                    self.pageEnd = true
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
                self.removeReadCout()
            }
            else {
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    private func removeReadCout() {
        //카운트가 맞지 않아서 일단 서버 리스트와 없으면 로컬 리스트 놈 지워준다.
        DBManager.ins.getAllChatMessage { messages, error in
            guard let messages = messages else { return }
            var delUserIds = [String]()
            for chat in messages {
                guard let from_user_id = chat.from_user_id, let to_user_id = chat.to_user_id else {
                    return
                }
                var isFind = false
                for item in self.listData {
                    if item["user_id"].stringValue == from_user_id
                        || item["user_id"].stringValue == to_user_id {
                        isFind = true
                        break
                    }
                }
                
                if (isFind == false) {
                    delUserIds.append(from_user_id)
                }
            }
            
            for delId in delUserIds {
                DBManager.ins.deleteChatMessageWithUserId(userId: delId, nil)
            }
            appDelegate.mainViewCtrl.updateUnReadMessageCount()
        }
        
//        DBManager.ins.getAllChatMessage { messages, error in
//            guard let messages = messages else { return }
//            for chat in messages {
//                guard let userid = chat.from_user_id else {
//                    return
//                }
//                print("after: \(userid)")
//            }
//        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnJim {
            
            let vc = MyFrendsListViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnDelAll {
            CAlertViewController.show(type: .alert, title: NSLocalizedString("activity_txt22", comment: "대화삭제"), message: NSLocalizedString("activity_txt142", comment: "모든 대화가 삭제됩니다."), actions: [.cancel , .ok]) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                if index == 1 {
                    ApiManager.ins.requestMssageAllDelete(param: ["user_id":ShareData.ins.myId]) { (res) in
                        let isSuccess = res["isSuccess"].stringValue
                        if isSuccess == "01" {
                            self.dataRest()
                            DBManager.ins.deleteAllChatMessage { reulst, error in
                                appDelegate.mainViewCtrl.updateUnReadMessageCount()
                            }
                        }
                        else {
                            self.showErrorToast(res)
                        }
                    } failure: { (error) in
                        self.showErrorToast(error)
                    }
                }
            }
        }
        else if sender == btnBlock {
            let vc = MyBlockListViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
    }
    
    override func notificationHandler(_ notification: NSNotification) {
        
        if (notification.name == Notification.Name(PUSH_DATA)) {
            guard let type = notification.object as? PushType, let userInfo = notification.userInfo as?[String:Any] else {
                return
            }
            
            let info = JSON(userInfo)
            if type == .chat {
                self.dataRest()
            }
            else if type == .msgDel {
                let seq = info["seq"].stringValue
                let to_user_id = info["to_user_id"].stringValue
                
                var findUser:JSON? = nil
                for item in listData {
                    let message_key = item["seq"].stringValue
                    if message_key == seq {
                        findUser = item
                        break
                    }
                }
                guard let user = findUser else {
                    return
                }
                
                let user_name = user["user_name"].stringValue
//                self.showToastWindow("\(user_name)님이 대화방을 삭제했습니다.")
                self.showToastWindow(NSLocalizedString("activity_txt244", comment: "삭제된 대화방 입니다!!"))
                
                self.dataRest()
            }
        }
    }
}
extension ChattingListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ChattingCell.identifier) as? ChattingCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed(ChattingCell.identifier, owner: nil, options: nil)?.first as? ChattingCell
        }
        if indexPath.row < listData.count {
            let item = listData[indexPath.row]
            cell?.configurationData(item, completion: { selItem, action in
                guard let selItem = selItem as? JSON else {
                    return
                }
                if action == 100 {
                    if ShareData.ins.isReview == false {
                        let vc = RankDetailViewController.instantiateFromStoryboard(.main)!
                        vc.passData = selItem
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            })
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = ChattingViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
    }
}

extension ChattingListViewController: UIScrollViewDelegate {
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