//
//  VideoListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
import CRRefresh

class VideoListViewController: BaseViewController {
    var sortType: SortedType = .mail
    var listType: ListType = .table
    
    @IBOutlet weak var centerSelMarkView: NSLayoutConstraint!
    @IBOutlet weak var btnListType: CButton!
    @IBOutlet weak var btnFemail: CButton!
    @IBOutlet weak var btnMail: CButton!
    @IBOutlet weak var btnTotal: CButton!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "VideoColCell", bundle: nil), forCellWithReuseIdentifier: "VideoColCell")
        }
    }
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        decorationUI()
        toggleListType()
        selectedSortedBtn()
        dataRest()
        let footerview = UIView.init()
        footerview.backgroundColor = UIColor.systemGray6
        tblView.tableFooterView = footerview
        tblView.cr.addHeadRefresh { [weak self] in
            self?.dataRest()
        }
        collectionView.cr.addHeadRefresh { [weak self] in
            self?.dataRest()
        }
    }
    
    func decorationUI() {
        let imgNor = UIImage.image(from: RGB(120, 120, 130))
        let imgSel = UIImage.image(from: RGB(230, 100, 100))
        
        btnTotal.setBackgroundImage(imgNor, for: .normal)
        btnTotal.setBackgroundImage(imgSel, for: .selected)
        btnTotal.setTitle(SortedType.total.displayName(), for: .normal)
        
        btnFemail.setBackgroundImage(imgNor, for: .normal)
        btnFemail.setBackgroundImage(imgSel, for: .selected)
        btnFemail.setTitle(SortedType.femail.displayName(), for: .normal)
        
        btnMail.setBackgroundImage(imgNor, for: .normal)
        btnMail.setBackgroundImage(imgSel, for: .selected)
        btnMail.setTitle(SortedType.mail.displayName(), for: .normal)
        
        let layout = CFlowLayout.init()
        layout.numberOfColumns = 3
        layout.delegate = self
        layout.lineSpacing = 2
        layout.secInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        self.collectionView.collectionViewLayout = layout
    }
    
    func selectedSortedBtn() {
        if (sortType == .femail) {
            btnTotal.isSelected = false
            btnFemail.isSelected = true
            btnMail.isSelected = false
        }
        else if(sortType == .mail ) {
            btnTotal.isSelected = false
            btnFemail.isSelected = false
            btnMail.isSelected = true
        }
        else {
            btnTotal.isSelected = true
            btnFemail.isSelected = false
            btnMail.isSelected = false
        }
    }
    func toggleListType() {
        if listType == .collection {
            btnListType.isSelected = true
            centerSelMarkView.constant = 15
            
            collectionView.isHidden = false
            tblView.isHidden = true
        }
        else {
            btnListType.isSelected = false
            centerSelMarkView.constant = -15
            
            collectionView.isHidden = true
            tblView.isHidden = false
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if (sender == btnListType) {
            btnListType.isSelected = !sender.isSelected
            if (btnListType.isSelected) {
                self.listType = .collection
            }
            else {
                self.listType = .table
            }
            toggleListType()
            self.dataRest()
        }
        else if (sender == btnTotal) {
            sortType = .total
            self.selectedSortedBtn()
            self.dataRest()
        }
        else if (sender == btnFemail) {
            sortType = .femail
            self.selectedSortedBtn()
            self.dataRest()
        }
        else if (sender == btnMail) {
            sortType = .mail
            self.selectedSortedBtn()
            self.dataRest()
        }
    }
    
    func dataRest() {
        pageNum = 1
        pageEnd = false
        requestCamTalkList()
        if self.listType == .table, listData.count > 0 {
            self.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        else if listData.count > 0 {
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    func addData() {
        requestCamTalkList()
    }
    func requestCamTalkList() {
        if pageEnd == true {
            return
        }
        
        var param: [String:Any] = [:]
        param["app_type"] = ShareData.instance.appType
        param["user_id"] = ShareData.instance.userId
        param["my_sex"] = ShareData.instance.mySex.rawValue
        param["pageNum"] = pageNum
        param["search_sex"] = sortType.key()
        param["search_list"] = listType.rawValue
        
        ApiManager.ins.requestCamTalkList(param: param) { (resonse) in
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
                
                if self.listType == .table {
                    self.tblView.cr.endHeaderRefresh()
                    if (self.listData.count > 0) {
                        self.tblView.isHidden = false
                        self.tblView.reloadData()
                    }
                    else {
                        self.tblView.isHidden = true
                    }
                }
                else {
                    self.collectionView.cr.endHeaderRefresh()
                    if (self.listData.count > 0) {
                        self.collectionView.isHidden = false
                        
                        self.collectionView.reloadData()
                    }
                    else {
                        self.collectionView.isHidden = true
                    }
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
extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CamTblCell") as? CamTblCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("CamTblCell", owner: nil, options: nil)?.first as? CamTblCell
        }
        if (indexPath.row < listData.count) {
            let item = listData[indexPath.row]
            cell?.configurationData(item)
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension VideoListViewController: UICollectionViewDataSource, UICollectionViewDelegate, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoColCell", for: indexPath) as! VideoColCell
        if (indexPath.row < listData.count) {
            let item = listData[indexPath.row]
            cell.configurationData(item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        let height = ceil(1.2 * (collectionView.bounds.size.width/3))
        return height
    }
}

extension VideoListViewController: UIScrollViewDelegate {
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
