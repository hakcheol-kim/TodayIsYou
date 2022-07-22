//
//  CamTalkListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
import CRRefresh
import Lightbox

class CamTalkListViewController: MainActionViewController {
//    @IBOutlet weak var btnListType: ListTypeButton!
    
    @IBOutlet weak var listTypeView: UIView!
    @IBOutlet weak var btnConnectUser: CButton!
    @IBOutlet weak var btnFemail: CButton!
    @IBOutlet weak var btnMail: CButton!
    @IBOutlet weak var btnTotal: CButton!
    @IBOutlet weak var btnNoti: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnImageMode: CButton!
    @IBOutlet weak var btnListMode: CButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "CamTalkColCell", bundle: nil), forCellWithReuseIdentifier: "CamTalkColCell")
        }
    }
    var sortType: SortedType = .mail
    var listType: ListType = .text
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var didScroll: ((_ direction:ScrollDirection, _ offsetY:CGFloat) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        self.listType = appDelegate.mainViewCtrl.videoListType
        listTypeView.isHidden = ShareData.ins.isReview
        
        decorationUI()
        toggleListType()
        selectedSortedBtn()
        dataRest()
        let footerview = UIView.init()
        footerview.backgroundColor = UIColor.systemGray6
        tblView.tableFooterView = footerview
        
        tblView.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            self?.dataRest()
        }
        collectionView.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            self?.dataRest()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestGetPoint()
    }
    func decorationUI() {
        
        let imgNor = UIImage.color(from: .appColor(.grayButtonBg))
        let imgSel = UIImage.color(from: .appColor(.appColor))
        
        btnTotal.setBackgroundImage(imgNor, for: .normal)
        btnTotal.setBackgroundImage(imgSel, for: .selected)
        btnTotal.setTitleColor(.appColor(.gray125), for: .normal)
        btnTotal.setTitleColor(.appColor(.whiteText), for: .selected)
        
        btnFemail.setBackgroundImage(imgNor, for: .normal)
        btnFemail.setBackgroundImage(imgSel, for: .selected)
        btnFemail.setTitleColor(.appColor(.gray125), for: .normal)
        btnFemail.setTitleColor(.appColor(.whiteText), for: .selected)
        
        btnMail.setBackgroundImage(imgNor, for: .normal)
        btnMail.setBackgroundImage(imgSel, for: .selected)
        btnMail.setTitleColor(.appColor(.gray125), for: .normal)
        btnMail.setTitleColor(.appColor(.whiteText), for: .selected)
        
        btnConnectUser.setBackgroundImage(imgNor, for: .normal)
        btnConnectUser.setBackgroundImage(imgSel, for: .selected)
        btnConnectUser.setTitleColor(.appColor(.gray125), for: .normal)
        btnConnectUser.setTitleColor(.appColor(.whiteText), for: .selected)
        
        btnTotal.titleLabel?.numberOfLines = 0
        btnFemail.titleLabel?.numberOfLines = 0
        btnMail.titleLabel?.numberOfLines = 0
        btnConnectUser.titleLabel?.numberOfLines = 0
        
        btnTotal.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        btnFemail.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        btnMail.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        btnConnectUser.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        
        btnTotal.titleLabel?.textAlignment = .center
        btnFemail.titleLabel?.textAlignment = .center
        btnMail.titleLabel?.textAlignment = .center
        btnConnectUser.titleLabel?.textAlignment = .center
        
        btnConnectUser.addFlexableHeightConstraint()
        
        let layout = CFlowLayout.init()
        layout.numberOfColumns = 3
        layout.delegate = self
        layout.lineSpacing = 2
        layout.secInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        self.collectionView.collectionViewLayout = layout
//        self.collectionView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        
        btnNoti.isHidden = true
        if ShareData.ins.mySex == .femail {
            btnNoti.isHidden = false
            btnNoti.setImage(nil, for: .normal)
            btnNoti.titleLabel?.numberOfLines = 0
            btnNoti.setTitle(NSLocalizedString("activity_txt114", comment: ""), for: .normal)
            btnNoti.titleEdgeInsets = .zero
            btnNoti.addFlexableHeightConstraint()
        }
        self.view.layoutIfNeeded()
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
        if listType == .image {
            collectionView.isHidden = false
            tblView.isHidden = true
            btnImageMode.tintColor = .appColor(.appColor)
            btnListMode.tintColor = .appColor(.gray125)
            btnImageMode.isSelected = true
            btnListMode.isSelected = !btnImageMode.isSelected
        }
        else {
            collectionView.isHidden = true
            tblView.isHidden = false
            btnImageMode.tintColor = .appColor(.gray125)
            btnListMode.tintColor = .appColor(.appColor)
            btnImageMode.isSelected = false
            btnListMode.isSelected = !btnImageMode.isSelected
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnImageMode {
            self.listType = .image
            appDelegate.mainViewCtrl.videoListType = self.listType
            self.toggleListType()
            self.dataRest()
        }
        else if sender == btnListMode {
            self.listType = .text
            appDelegate.mainViewCtrl.videoListType = self.listType
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
        else if sender == btnConnectUser {
            let vc = ConnectUserListViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
    }
    
    func dataRest() {
        pageNum = 1
        pageEnd = false
        requestCamTalkList()
        if self.listType == .text {
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
                
                if self.listType == .text {
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
        if ShareData.ins.serverLanguageCode == "kr" {
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
                        self.showToast(NSLocalizedString("activity_txt08", comment: "1회 이상 결제한 유저님만 크게 볼 수 있습니다!!"))
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
                        self.showToast(NSLocalizedString("activity_txt08", comment: "1회 이상 결제한 유저님만 크게 볼 수 있습니다!!"))
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
        if velocityY > 0 {
//            print("down")
            self.didScroll?(.down, scrollView.contentOffset.y)
        }
        else if velocityY < 0 {
//            print("up")
            self.didScroll?(.up, scrollView.contentOffset.y)
        }
    }
}
