//
//  TalkListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON

class TalkListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnGender: CButton!
    @IBOutlet weak var btnArea: CButton!
    @IBOutlet weak var lbNotice: UILabel!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.instance.mySex.transGender()
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
        param["app_type"] = ShareData.instance.appType
        param["user_id"] = ShareData.instance.userId
        param["pageNum"] = pageNum
        param["search_sex"] = searchSex.rawValue
        param["search_area"] = searchArea
        
        ApiManager.ins.requestTalkList(param: param) { (resonse) in
            self.canRequest = true
            let result = resonse?["result"].arrayValue
            let isSuccess = resonse?["isSuccess"].stringValue
            if isSuccess == "01", let result = result {
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
