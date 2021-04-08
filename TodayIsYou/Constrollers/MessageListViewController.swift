//
//  MessageListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON

class MessageListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnDelAll: UIButton!
    @IBOutlet weak var btnJim: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.ins.userSex.transGender()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let footerview = UIView.init()
        footerview.backgroundColor = UIColor.systemGray6
        tblView.tableFooterView = footerview
        tblView.cr.addHeadRefresh { [weak self] in
            self?.dataRest()
        }
        
        self.dataRest()
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
        
        param["user_id"] = ShareData.ins.userId
        param["pageNum"] = pageNum
        ApiManager.ins.requestMsgList(param: param) { (response) in
            self.canRequest = true
            let result = response["result"].arrayValue
            let isSuccess = response["isSuccess"].stringValue
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
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnJim {
            let vc = MyFrendsListViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnDelAll {
            CAlertViewController.show(type: .alert, title: "대화삭제", message: "모든 대화가 삭제됩니다.", actions: [.cancel , .ok]) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                if index == 1 {
                    ApiManager.ins.requestMssageAllDelete(param: ["user_id":ShareData.ins.userId]) { (res) in
                        let isSuccess = res["isSuccess"].stringValue
                        if isSuccess == "01" {
                            self.dataRest()
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
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
    }
}
extension MessageListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MessageTblCell") as? MessageTblCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("MessageTblCell", owner: nil, options: nil)?.first as? MessageTblCell
        }
        if indexPath.row < listData.count {
            let item = listData[indexPath.row]
            cell?.configurationData(item)
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = ChattingViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
    }
}

extension MessageListViewController: UIScrollViewDelegate {
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
