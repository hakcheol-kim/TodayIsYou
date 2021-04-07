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
    
    func checkPointPhone() {
        
    }
    
    override func presentCamTalkAlert() {
        let customView = Bundle.main.loadNibNamed("CamTalkAlertView", owner: nil, options: nil)?.first as! CamTalkAlertView
        
        let vc = CAlertViewController.init(type: .custom, title: "", message: nil, actions: nil) { (vcs, selItem, index) in
            vcs.dismiss(animated: true, completion: nil)
            if index == 1 {
                print("음성")
                self.actionAlertPhoneCall()
            }
            else if index == 2 {
                print("영상")
                self.actionAlertCamTalkCall()
            }
        }
        
        vc.addCustomView(customView)
        customView.configurationData(selectedUser)
        vc.iconImgName = customView.getImgUrl()
        vc.aletTitle = customView.getTitleAttr()
        
        if ShareData.ins.userSex.rawValue == "남" {
            if isMyFriend {
                customView.lbMsg1.text = "대화 목록에 있는 상대는 신청이 무료입니다"
                customView.lbMsg2.isHidden = true
            }
            else {
                customView.lbMsg2.isHidden = false
                var camPoint = "0"
                var phonePoint = "0"
                
                if let p1 = ShareData.ins.dfsObjectForKey(DfsKey.camOutUserPoint) as? NSNumber, let p2 = ShareData.ins.dfsObjectForKey(DfsKey.phoneOutUserPoint) as? NSNumber {
                    camPoint = p1.stringValue.addComma()
                    phonePoint = p2.stringValue.addComma()
                }
                customView.lbMsg1.text = "영상 음성 채팅 신청시 \(0) 포인트가 차감 됩니다."
            }
        }
        else {
            customView.lbMsg2.isHidden = true
            customView.lbMsg1.text = "무료로 이용 가능합니다."
        }
        vc.reloadUI()
        customView.btnReport.addTarget(self, action: #selector(actionAlertReport), for: .touchUpInside)
        vc.btnIcon.addTarget(self, action: #selector(actionAlertProfile), for: .touchUpInside)
        vc.addAction(.cancel, "취소", UIImage(systemName: "xmark.circle.fill"), RGB(216, 216, 216))
        vc.addAction(.ok, "음성", UIImage(systemName: "phone.fill.arrow.up.right"), RGB(230, 100, 100))
        vc.addAction(.ok, "영상", UIImage(systemName: "arrow.up.right.video.fill"), RGB(230, 100, 100))
        self.present(vc, animated: true, completion: nil)
    }
  
    @objc private func actionAlertProfile() {
        if let presentedVc = presentedViewController {
            presentedVc.dismiss(animated: false, completion: nil)
        }
        
    }
    @objc private func actionAlertReport() {
        if let presentedVc = presentedViewController {
            presentedVc.dismiss(animated: false, completion: nil)
        }
        self.presentBlockAlert()
    }
    private func actionAlertPhoneCall() {
        
    }
    private func actionAlertCamTalkCall() {
    }
    
    func presentBlockAlert() {
        let user_name = self.selectedUser["user_name"].stringValue
        let user_id = self.selectedUser["user_id"].stringValue
        
        let alert = CAlertViewController.init(type: .alert, title: "\(user_name)님 신고하기", message: nil, actions: [.cancel, .ok]) { (vcs, selItem, index) in
            
            if (index == 1) {
                guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                    return
                }
                vcs.dismiss(animated: true, completion: nil)
                let param = ["user_name":user_name, "to_user_id":user_id, "user_id":ShareData.ins.userId, "memo":text]
                ApiManager.ins.requestReport(param: param) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        self.showToast("신고가 완료되었습니다.")
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
        alert.addTextView("내용을 입력해주세요.", UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
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
            cell?.didClickedClosure = {(_ selData, _ index)-> Void in
                guard let selData = selData else {
                    return
                }
                
                if index == 100 {
                    self.selectedUser = selData
                    self.checkAvaiableCamTalk()
                }
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.selectedUser = listData[indexPath.row]
        self.checkAvaiableCamTalk()
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
        self.selectedUser = listData[indexPath.row]
        self.checkAvaiableCamTalk()
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
