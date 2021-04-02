//
//  RankListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
class RankListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            
        }
    }
    
    var listData: [JSON] = []
    var topListData: [JSON] = []
    
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.ins.userSex.transGender()
    var listCount = 0
    var itemSize = CGSize.zero
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let footerview = UIView.init()
        footerview.backgroundColor = UIColor.systemGray6
        tblView.tableFooterView = footerview
        tblView.cr.addHeadRefresh { [weak self] in
            self?.listCount = 0
            self?.dataRest()
        }
        self.commitPagerView()
        self.dataRest()
    }
    
    func commitPagerView() {
        
        pagerView.register(UINib(nibName: "RankTopColCell", bundle: nil), forCellWithReuseIdentifier: "RankTopColCell")
        pagerView.automaticSlidingInterval = 3.0
        pagerView.isInfinite = true
        pagerView.decelerationDistance = FSPagerView.automaticDistance
        
        pagerView.interitemSpacing = 10
        let scale = CGFloat(0.9)
        self.itemSize = pagerView.frame.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        pagerView.itemSize = itemSize
        
        pagerView.delegate = self
        pagerView.dataSource = self
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
        if pageEnd == true || (listCount > 0 && (listData.count >= listCount)) {
            return
        }
        
        var param: [String:Any] = [:]
        param["user_id"] = ShareData.ins.userId
        param["pageNum"] = pageNum
        param["search_sex"] = searchSex.rawValue
        
        ApiManager.ins.requestRankingList(param: param) { (resonse) in
            self.canRequest = true
            let result = resonse["result"].arrayValue
            let isSuccess = resonse["isSuccess"].stringValue
            self.listCount = resonse["listCount"].intValue
            
            if isSuccess == "01" {
                if result.count == 0 {
                    self.pageEnd = true
                }
                else {
                    if self.pageNum == 1 {
                        self.listData = result
                        
                        if self.listData.count > 3 {
                            self.topListData.removeAll()
                            for i in 0..<3 {
                                let item = self.listData[i]
                                self.topListData.append(item)
                            }
                            self.commitPagerView()
                            self.pagerView.reloadData()
                        }
                    }
                    else {
                        self.listData.append(contentsOf: result)
                    }
                }
                
                self.tblView.cr.endHeaderRefresh()
                if (self.listData.count > 0) {
                    self.tblView.isHidden = false
                    self.pagerView.isHidden = false
                    self.tblView.reloadData()
                }
                else {
                    self.pagerView.isHidden = true
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

extension RankListViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return topListData.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "RankTopColCell", at: index) as! RankTopColCell
        let item = topListData[index]
        cell.configurationData(item)
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
    }
}

extension RankListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RankTblCell") as? RankTblCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("RankTblCell", owner: nil, options: nil)?.first as? RankTblCell
        }
        let item = listData[indexPath.row]
        cell?.configurationData(item)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = storyboard?.instantiateViewController(identifier: "RankDetailViewController") as! RankDetailViewController
        vc.passData = item
        AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
    }
}

extension RankListViewController: UIScrollViewDelegate {
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
