//
//  PhotoDetailViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/29.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class RankDetailTblCell: UITableViewCell {
    static let identifier = "RankDetailTblCell"
    
    @IBOutlet weak var ivThumb: UIImageViewAligned!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTalkTime: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data:JSON) {
        let out_point_time = data["out_point_time"].stringValue //" : 25560,
        let days = data["days"].stringValue //" : 37,
        let times = data["times"].stringValue //" : "00:35:26",
        let rownum = data["rownum"].intValue //" : 1,
        let user_sex = data["user_sex"].stringValue //" : "여",
        let reg_date = data["reg_date"].stringValue //" : "2021-02-22 17:07:31"
        
        
        let df = CDateFormatter.init()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss" // "2021-03-11 07:35:32
        var tStr = ""
        
        if let regDate = df.date(from: reg_date) {
            let curDate = Date()
            let comps = curDate - regDate

            if let month = comps.month, month > 0 {
                tStr = "\(month)달전"
            }
            else if let day = comps.day, day > 0 {
                tStr = String(format: "%ld일전", day)
            }
            else if let hour = comps.hour, hour > 0 {
                tStr = String(format: "%02ld시간 %02ld분전", hour, (comps.minute ?? 0))
            }
            else if let minute = comps.minute, minute > 0 {
                tStr = String(format: "%02ld분 %02ld초전", minute, (comps.second ?? 0))
            }
            else if let second = comps.second, second > 0 {
                tStr = String(format: "%02ld초전", second)
            }
        }
        lbTitle.text = out_point_time.maskOfSuffixLenght(2)
        lbDate.text = tStr
        lbTalkTime.text = "대화 : \(times)"
        ivThumb.image = Gender.defaultImg(user_sex)
    }
    
}

class RankDetailViewController: MainActionViewController {
    @IBOutlet var tblView: UITableView!
    @IBOutlet var btnBack: UIButton!
    
    var passData:JSON!
    var listData:[JSON] = []
    var headerView: RankDetailTblHeaderView!
    private let headerHeight: CGFloat = 500.0
    private let cutawayHeight: CGFloat = 0.0
    var headerMaskLayer:CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        tblView.estimatedRowHeight = tblView.rowHeight
        tblView.rowHeight = UITableView.automaticDimension
        
        self.configurationUi()
        self.requestRankDetail()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func configurationUi() {
        tblView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: tblView.bounds.width, height: 150))
        
        self.headerView = tblView.tableHeaderView as! RankDetailTblHeaderView
        tblView.tableHeaderView = nil
        tblView.addSubview(headerView)
        tblView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        tblView.contentOffset = CGPoint(x: 0, y: -headerHeight)
        headerView.configurationData(passData)
        
        headerView.didClickedClosure = {(selItem, action) ->Void in
            guard let selItem = selItem else {
                return
            }
            self.selUser = selItem
            if action == 0 {
                self.actionBlockAlert()
            }
            else if action == 1 {
                print("action msg")
                self.checkTalk()
            }
            else if action == 2 {
                self.selUser = selItem
                self.checkCamTalk()
            }
        }
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = headerMaskLayer
        
        updateHeaderView()
        
        let effectHeight = headerHeight - cutawayHeight/2
        tblView.contentInset = UIEdgeInsets(top: effectHeight, left: 0, bottom: 0, right: 0)
        tblView.contentOffset = CGPoint(x: 0, y: -effectHeight)
    }
    
    func updateHeaderView() {
        let effectHeight:CGFloat = headerHeight
        var headerRect = CGRect(x: 0, y: -effectHeight, width: tblView.bounds.width, height: headerHeight)
        
        if tblView.contentOffset.y < -effectHeight {
            headerRect.origin.y = tblView.contentOffset.y
            headerRect.size.height = -tblView.contentOffset.y + cutawayHeight/2
        }
        headerView.frame = headerRect
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height-cutawayHeight))
        headerMaskLayer?.path = path.cgPath
        
    }
    func requestRankDetail() {
        let user_id = passData["user_id"].stringValue
        let param = ["user_id":user_id]
        ApiManager.ins.requestRankDetail(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            let result = res["result"].arrayValue
            if isSuccess == "01" {
                self.listData = result
                self.tblView.reloadData()
            }
            else {
                self.showErrorToast(res)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func presentTalkMsgAlert() {
        var msg:String? = nil
        if let bbsPoint = ShareData.ins.dfsGet(DfsKey.userBbsPoint) as? NSNumber, bbsPoint.intValue > 0 {
            msg = "메세지 전송시 \(bbsPoint)P 소모됩니다."
        }
        
        let alert = CAlertViewController.init(type: .alert, title: "메세지 전송", message: msg, actions: [.cancel, .ok]) { (vcs, selItem, index)  in
            
            if index == 1 {
                guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                    self.showToast("내용을 입력해주세요.")
                    return
                }
                self.requestSendMsg(text)
                vcs.dismiss(animated: true, completion: nil)
            }
            else {
                vcs.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.iconImg = UIImage(systemName: "envelope.fill")
        alert.addTextView("입력해주세요.")
        alert.reloadUI()
        self.present(alert, animated: true, completion: nil)
    }
    
    func requestSendMsg(_ content:String) {
        var param:[String:Any] = [:]
        
        var friend_mode = "N"
        if isMyFriend {
            friend_mode = "Y"
        }
        var bbsPoint = 0
        if let p = ShareData.ins.dfsGet(DfsKey.userBbsPoint) as? NSNumber {
            bbsPoint = p.intValue
        }
        param["user_id"] = ShareData.ins.myId
        param["from_user_id"] = ShareData.ins.myId
        param["from_user_sex"] = ShareData.ins.mySex.rawValue
        param["to_user_id"] = passData["user_id"].stringValue
        param["to_user_name"] = passData["user_name"].stringValue
        param["memo"] = content
        param["user_bbs_point"] = bbsPoint
        param["point_user_id"] = ShareData.ins.myId
        param["friend_mode"] = friend_mode
        
        ApiManager.ins.requestSendTalkMsg(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "00" {
                let errorCode = res["errorCode"].stringValue
                if errorCode == "0002" {
                    self.showToast("탈퇴한 회원 입니다")
                }
                else if errorCode == "0003" {
                    self.showToast("차단 상태인 회원 입니다")
                }
                else {
                    self.showToast("오류!!")
                }
            }
            else {
                self.showToast("쪽지 전송 완료");
                //TODO:: Save local db
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    //show camtalk
    override func actionAlertPhoneCall() {
        
    }
    override func actionAlertCamTalkCall() {
    }
    override func actionBlockAlert() {
        let user_name = passData["user_name"].stringValue
        let user_id = passData["user_id"].stringValue
        
        let alert = CAlertViewController.init(type: .alert, title: "\(user_name)님 신고하기", message: nil, actions: [.cancel, .ok]) { (vcs, selItem, index) in
            
            if (index == 1) {
                guard let text = vcs.arrTextView.first?.text, text.isEmpty == false else {
                    return
                }
                vcs.dismiss(animated: true, completion: nil)
                let param = ["user_name":user_name, "to_user_id":user_id, "user_id":ShareData.ins.myId, "memo":text]
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
        alert.addTextView("신고 내용을 입력해주세요.", UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension RankDetailViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RankDetailTblCell.identifier) as? RankDetailTblCell else {
            return UITableViewCell()
        }
        let item = listData[indexPath.row]
        cell.configurationData(item)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 56
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateHeaderView()
    }
}
