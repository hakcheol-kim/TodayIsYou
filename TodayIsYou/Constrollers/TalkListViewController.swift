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
    var searchSex:String = ShareData.ins.mySex.transGender().rawValue
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
            lbGender.text = Gender.localizedString(searchSex)
        }
        
        if let lbArea = btnArea.viewWithTag(100) as? UILabel {
            lbArea.text = NSLocalizedString("root_display_txt23", comment: "전체")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestGetPoint()
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
        param["user_id"] = ShareData.ins.myId
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
            let vc = PopupListViewController.initWithType(.normal, "join_activity07".localized, ["root_display_txt21".localized, "root_display_txt20".localized], nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: false, completion: nil)
                
                guard let selItem = selItem as? String, let lbGender = self.btnGender.viewWithTag(100) as? UILabel else {
                    return
                }
                lbGender.text = selItem
                if selItem == "Male" || selItem == "남" {
                    self.searchSex = "남"
                }
                else {
                    self.searchSex = "여"
                }
                self.dataRest()
            }
            self.presentPanModal(vc)
        }
        else if sender == btnArea {

            var area = [String]()
            for i in 0..<17 {
                let key = "area_\(i)"
                area.append(key.localized)
            }
            area.insert("root_display_txt19".localized, at: 0)
            let vc = PopupListViewController.initWithType(.normal, "join_activity09".localized, area, nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                
                guard let selItem = selItem as? String, let lbArea = self.btnArea.viewWithTag(100) as? UILabel  else {
                    return
                }
                
                lbArea.text = selItem
                if selItem == "전체" || selItem == "All" {
                    self.searchArea = ""
                }
                else {
                    self.searchArea = Area.severKey(selItem)
                }
                self.dataRest()
            }
            self.presentPanModal(vc)
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
        
        let item = listData[indexPath.row]
        cell?.configurationData(item)
        cell?.didClickedClosure = {(_ selData, _ action)-> Void in
            guard let selData = selData else {
                return
            }
            
            switch action {
            case 100:   //뒤에 이미지 터치 액션
                if let inappCnt = ShareData.ins.dfsGet(DfsKey.inappCnt) as? NSNumber, inappCnt.intValue > 0 {
                    let user_id = selData["user_id"].stringValue
                    let file_name = selData["file_name"].stringValue
                    if let imgUrl = Utility.thumbnailUrl(user_id, file_name) {
                        self.showPhoto(imgUrls: [imgUrl])
                    }
                }
                else {
                    self.showToast("1회 이상 결제한 유저님만 크게 볼 수 있습니다!!");
                }
                break
            case 101: //프로파일 터치
                if let inappCnt = ShareData.ins.dfsGet(DfsKey.inappCnt) as? NSNumber, inappCnt.intValue > 0 {
                    let user_id = selData["user_id"].stringValue
                    let user_image = selData["user_image"].stringValue
                    if let imgUrl = Utility.thumbnailUrl(user_id, user_image) {
                        self.showPhoto(imgUrls: [imgUrl])
                    }
                }
                else {
                    self.showToast("1회 이상 결제한 유저님만 크게 볼 수 있습니다!!");
                }
                break
            case 102:   //메세지 아이콘
                self.selUser = selData
                self.checkTalk()
                break
            default:
                break
            }
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selUser = listData[indexPath.row]
        self.checkTalk()
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
