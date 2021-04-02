//
//  CamTalkListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON
import CRRefresh

class CamTalkListViewController: BaseViewController {
    
    @IBOutlet weak var centerSelMarkView: NSLayoutConstraint!
    @IBOutlet weak var btnListType: CButton!
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
    var selData:JSON!
    
    let group = DispatchGroup.init()
    let queue = DispatchQueue.global()
    var isMyBlock = false
    var isBlocked = false
    var isMyFriend = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getBlackList(toUserId:String) {
        group.enter()
        self.isBlocked = false
        let prama = ["black_user_id" : ShareData.ins.userId, "user_id" : toUserId]
        ApiManager.ins.requestGetBlockList(param: prama) { (response) in
            self.group.leave()
            if response["isSuccess"].stringValue == "01" {
                self.isBlocked = true
            }
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
        }
    }
    //내가 차단한 리스트
    func getMyBlockList(toUserId:String) {
        group.enter()
        self.isMyBlock = false
        let prama = ["black_user_id":toUserId, "user_id": ShareData.ins.userId]
        ApiManager.ins.requestGetBlockList(param: prama) { (response) in
            self.group.leave()
            if response["isSuccess"].stringValue == "01" {
                self.isMyBlock = true
            }
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
        }
    }
    func getMyFriendCheck(toUserId:String) {
        group.enter()
        self.isMyFriend = false
        let param = ["from_user_id": ShareData.ins.userId, "to_user_id":toUserId]
        ApiManager.ins.requestCheckMyFriend(param: param) { (response) in
            self.group.leave()
            if response["isSuccess"].stringValue == "01" {
                self.isMyFriend = true
            }
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
        }
    }
    func getUserInfo(toUserId:String) {
        self.group.enter()
        let param = ["app_type": appType, "user_id":toUserId]
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            self.group.leave()
            self.selData = response
        } failure: { (error) in
            self.group.leave()
            self.showErrorToast(error)
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
        param["app_type"] = appType
        param["user_id"] = ShareData.ins.userId
        param["my_sex"] = ShareData.ins.userSex.rawValue
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
   
    @objc func onClickedAlertProfile(_ sender: UIButton) {
        if let presentedVc = self.presentedViewController {
            presentedVc.dismiss(animated: true, completion: nil)
        }
        guard let selData = selData else {
            return
        }
        let k = 0
    }
    @objc func onClickedAlertBlock(_ sender: UIButton)  {
        if let presentedVc = self.presentedViewController {
            presentedVc.dismiss(animated: true, completion: nil)
        }
        guard let selData = selData else {
            return
        }
        let k = 0
    }
    
    func checkAvailableCamTalk() {
        let user_sex = self.selData["user_sex"].stringValue
        if  user_sex == ShareData.ins.userSex.rawValue {
            self.showToast("같은 성별은 영상채팅이 불가합니다!!")
            return
        }
        
        let toUserId = selData["user_id"].stringValue
        self.getUserInfo(toUserId: toUserId)
        self.getBlackList(toUserId: toUserId)
        self.getMyBlockList(toUserId: toUserId)
        self.getMyFriendCheck(toUserId: toUserId)
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                if  self.isBlocked && self.isMyBlock {
                    self.showToast("쌍방이 차단했습니다!!")
                }
                else if self.isBlocked {
                    self.showToast("상대가 차단 했습니다!!")
                }
                else if self.isMyBlock {
                    self.showToast("내가 차단 했습니다!!")
                }
                else {
                    if ("남" == ShareData.ins.userSex.rawValue) {
                        if self.isMyFriend {
                            self.showCamTalkAlert()
                        }
                        else {
                            
                        }
                    }
                    else {
                        self.showCamTalkAlert()
                    }
                }
            }
        }
        print("job enter finished")
    }
    
    func showCamTalkAlert() {
        let vc = CAlertViewController.init(type: .alert, title: nil, message: nil, actions: nil) { (vcs, selItem, index) in
            vcs.dismiss(animated: true, completion: nil)
            if index == 1 {
                print("음성")
            }
            else if index == 2 {
                print("영상")
            }
        }
        
        let customView = Bundle.main.loadNibNamed("CamTalkAlertView", owner: nil, options: nil)?.first as! CamTalkAlertView
        customView.configurationData(selData)
        
        customView.btnProfile.addTarget(self, action: #selector(self.onClickedAlertProfile(_ :)), for: .touchUpInside)
        customView.btnReport.addTarget(self, action: #selector(self.onClickedAlertBlock(_ :)), for: .touchUpInside)
        vc.addCustomView(customView)

        vc.addAction(.normal, "취소", UIImage(systemName: "xmark.circle.fill"), RGB(216, 216, 216))
        vc.addAction(.normal, "음성", UIImage(systemName: "phone.fill.arrow.up.right"), RGB(230, 100, 100))
        vc.addAction(.normal, "영상", UIImage(systemName: "arrow.up.right.video.fill"), RGB(230, 100, 100))
        self.present(vc, animated: true, completion: nil)
    }
    
    func checkPointPhone() {
        
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
            cell?.didClickedClosure = {(_ selData, _ index)-> Void in
                guard let selData = selData else {
                    return
                }
                self.selData = selData
                if index == 100 {
                    self.checkAvailableCamTalk()
                }
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.selData = listData[indexPath.row]
        self.checkAvailableCamTalk()
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
        self.selData = listData[indexPath.row]
        self.checkAvailableCamTalk()
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
