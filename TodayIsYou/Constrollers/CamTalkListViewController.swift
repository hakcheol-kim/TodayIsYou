//
//  CamTalkListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
import CRRefresh

class CamTalkListViewController: MainActionViewController {
    
    @IBOutlet weak var btnListType: UIButton!
    @IBOutlet weak var btnFemail: CButton!
    @IBOutlet weak var btnMail: CButton!
    @IBOutlet weak var btnTotal: CButton!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "CamTalkColCell", bundle: nil), forCellWithReuseIdentifier: "CamTalkColCell")
        }
    }
    var sortType: SortedType = .mail
    var listType: ListType = .table
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        
        self.listType = AppDelegate.ins.mainViewCtrl.videoListType
        if self.listType == .collection {
            btnListType.isSelected = true
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.ins.mainViewCtrl.updateNaviPoint()
    }
    func decorationUI() {
        let imgNor = UIImage.color(from: RGB(120, 120, 130))
        let imgSel = UIImage.color(from: RGB(230, 100, 100))
        
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
        //메모리 세이브 리스트 타입
        
        if listType == .collection {
//            btnListType.isSelected = true
//            centerSelMarkView.constant = 15
            
            collectionView.isHidden = false
            tblView.isHidden = true
        }
        else {
//            btnListType.isSelected = false
//            centerSelMarkView.constant = -15
            
            collectionView.isHidden = true
            tblView.isHidden = false
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if (sender == btnListType) {
            sender.isSelected = !sender.isSelected
            if (btnListType.isSelected) {
                self.listType = .collection
            }
            else {
                self.listType = .table
            }
            AppDelegate.ins.mainViewCtrl.videoListType = self.listType
            self.toggleListType()
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
        if self.listType == .table {
            self.tblView.setContentOffset(CGPoint.zero, animated: true)
        }
        else if listData.count > 0 {
            self.collectionView.setContentOffset(CGPoint.zero, animated: true)
//            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
        param["app_type"] = appType
        param["user_id"] = ShareData.ins.myId
        param["my_sex"] = ShareData.ins.mySex.rawValue
        param["pageNum"] = pageNum
        param["search_sex"] = sortType.key()
        param["search_list"] = listType.rawValue
        
        ApiManager.ins.requestCamTalkList(param: param) { (resonse) in
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
    
    func checkPointPhone() {
        
    }
    
    override func actionBlockAlert() {
        let user_name = self.selUser["user_name"].stringValue
        let user_id = self.selUser["user_id"].stringValue
      
        var title = ""
        if ShareData.ins.languageCode == "ko" {
            title = "\(user_name)님 \(NSLocalizedString("activity_txt495", comment: "신고하기"))"
        }
        else {
            title = "\(user_name) \(NSLocalizedString("activity_txt495", comment: "신고하기"))"
        }
        
        let alert = CAlertViewController.init(type: .alert, title: title, message: nil, actions: [.cancel, .ok]) { (vcs, selItem, index) in
            
            if (index == 1) {
                guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                    return
                }
                vcs.dismiss(animated: true, completion: nil)
                let param = ["user_name":user_name, "to_user_id":user_id, "user_id":ShareData.ins.myId, "memo":text]
                ApiManager.ins.requestReport(param: param) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        self.showToast(NSLocalizedString("activity_txt246", comment: "신고 완료"))
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
        alert.addTextView(NSLocalizedString("activity_txt497", comment: "신고내용"), UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        self.present(alert, animated: true, completion: nil)
    }
}
extension CamTalkListViewController: UITableViewDataSource, UITableViewDelegate {
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
            cell?.didClickedClosure = {(_ selData, _ action)-> Void in
                guard let selData = selData else {
                    return
                }
                
                switch action {
                case 100:
                    if let inappCnt = ShareData.ins.dfsGet(DfsKey.inappCnt) as? NSNumber, inappCnt.intValue > 0 {
                        let user_id = selData["user_id"].stringValue
                        let file_name = selData["file_name"].stringValue
                        if let imgUrl = Utility.thumbnailUrl(user_id, file_name) {
                            self.showPhoto(imgUrls: [imgUrl])
                        }
                    }
                    else {
                        self.showToast(NSLocalizedString("activity_txt69", comment: "1회 이상 결제한 유저님만 크게 볼 수 있습니다!!"))
                    }
                    break
                case 101:
                    if let inappCnt = ShareData.ins.dfsGet(DfsKey.inappCnt) as? NSNumber, inappCnt.intValue > 0 {
                        let user_id = selData["user_id"].stringValue
                        let user_image = selData["user_image"].stringValue
                        if let imgUrl = Utility.thumbnailUrl(user_id, user_image) {
                            self.showPhoto(imgUrls: [imgUrl])
                        }
                    }
                    else {
                        self.showToast(NSLocalizedString("activity_txt69", comment: "1회 이상 결제한 유저님만 크게 볼 수 있습니다!!"))
                    }
                    break
                case 102:
                    self.selUser = selData
                    self.checkCamTalk()
                    break
                default:
                    break
                }
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.selUser = listData[indexPath.row]
        self.checkCamTalk()
    }
}

extension CamTalkListViewController: UICollectionViewDataSource, UICollectionViewDelegate, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CamTalkColCell", for: indexPath) as! CamTalkColCell
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.selUser = listData[indexPath.row]
        self.checkCamTalk()
    }
}

extension CamTalkListViewController: UIScrollViewDelegate {
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
