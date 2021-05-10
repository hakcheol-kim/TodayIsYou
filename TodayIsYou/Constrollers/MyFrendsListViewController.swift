//
//  MyFrendsListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class MyFrendsCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageViewAligned!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var btnVideoCall: CButton!
    
    var item:JSON!
    static let identifier = "MyFrendsCell"
    var onClickedClouser:((_ item:JSON?, _ action:Int) ->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        btnVideoCall.layer.cornerRadius = btnVideoCall.bounds.height/2;
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configurationData(_ item:JSON) {
        self.item = item
        let to_user_sex = item["to_user_sex"].stringValue
        let to_user_name = item["to_user_name"].stringValue
        let page = item["page"].numberValue
        let user_file = item["user_file"].stringValue
        let my_id = item["my_id"].stringValue
        let seq = item["seq"].numberValue
        let rownum = item["rownum"].numberValue
        let to_user_age = item["to_user_age"].stringValue
        let to_user_id = item["to_user_id"].stringValue
        
        ivProfile.image = Gender.defaultImg(to_user_sex)
        if let url = Utility.thumbnailUrl(to_user_id, user_file) {
            ivProfile.setImageCache(url)
        }
        lbTitle.text = to_user_name
        let result = "\(to_user_age), \(to_user_sex)"
        let attr = NSMutableAttributedString.init(string: result)
        attr.addAttribute(.foregroundColor, value: RGB(230, 100, 100), range: (result as NSString).range(of: to_user_sex))
        lbSubTitle.attributedText = attr
        
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnVideoCall {
            self.onClickedClouser?(item, 100)
        }
    }
    
}
class MyFrendsListViewController: MainActionViewController {

    @IBOutlet weak var tblView: UITableView!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.ins.mySex.transGender()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, "찜목록", #selector(actionNaviBack))
        let footerview = UIView.init()
        footerview.backgroundColor = UIColor.systemGray6
        tblView.tableFooterView = footerview
        tblView.cr.addHeadRefresh { [weak self] in
            self?.dataRest()
        }
        
        self.dataRest()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func dataRest() {
        pageNum = 1
        pageEnd = false
        requestMyFrendList()
        if listData.count > 0 {
            self.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    func addData() {
        requestMyFrendList()
    }
    func requestMyFrendList() {
        if pageEnd == true {
            return
        }
        
        var param:[String:Any] = [:]
        
        param["user_id"] = ShareData.ins.myId
        param["pageNum"] = pageNum
        
        ApiManager.ins.requestMyFriendsList(param: param) { (response) in
            self.canRequest = true
            let result = response["result"].arrayValue
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01"{
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
    
    func requestDeleteMyFriend(_ seq:NSNumber) {
        let param = ["seq":seq]
        ApiManager.ins.requestDeleteMyFriend(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.dataRest()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
    
    override func actionBlockAlert() {
        let user_name = self.selUser["user_name"].stringValue
        let user_id = self.selUser["user_id"].stringValue
        
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
extension MyFrendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyFrendsCell.identifier) as? MyFrendsCell else {
            return UITableViewCell()
        }

        let item = listData[indexPath.row]
        cell.configurationData(item)
        cell.onClickedClouser = { (item, action) -> Void in
            guard let item = item else {
                return
            }
            if action == 100 {
                self.selUser = item
                self.selUser["user_id"] = item["to_user_id"]
                self.checkCamTalk()
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = listData[indexPath.row]
            let seq = item["seq"].numberValue
            self.requestDeleteMyFriend(seq)
            listData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MyFrendsListViewController: UIScrollViewDelegate {
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
