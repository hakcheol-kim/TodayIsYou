//
//  MyBlockListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class MyBlockListCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageViewAligned!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var btnDelete: CButton!
    
    var onClickedClouser:((_ item:JSON?, _ action:Int) ->Void)?
    
    var item:JSON!
    static let identifier = "MyBlockListCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnDelete.layer.cornerRadius = btnDelete.bounds.height/2;
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configurationData(_ item:JSON) {
        self.item = item
        let user_name = item["user_name"].stringValue
        let seq = item["seq"].stringValue
        let user_id = item["user_id"].stringValue
        let user_age = item["user_age"].stringValue
        let black_user_id = item["black_user_id"].stringValue
        let reg_date = item["reg_date"].stringValue
        let user_sex = item["user_sex"].stringValue
        let user_img = item["user_img"].stringValue
        
        ivProfile.image = Gender.defaultImg(user_sex)
        if let url = Utility.thumbnailUrl(black_user_id, user_img) {
            ivProfile.setImageCache(url)
        }
        lbTitle.text = user_name
        let result = "\(Age.localizedString(user_age)), \(Gender.localizedString(user_sex))"
        let attr = NSMutableAttributedString.init(string: result)
        attr.addAttribute(.foregroundColor, value: RGB(230, 100, 100), range: (result as NSString).range(of: user_sex))
        lbSubTitle.attributedText = attr
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnDelete {
            self.onClickedClouser?(item, 100)
        }
    }
}

/// class
class MyBlockListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    var selItem:JSON!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.ins.mySex.transGender()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, NSLocalizedString("activity_txt165", comment: "차단목록"), #selector(actionNaviBack))
        let footerview = UIView.init()
        footerview.backgroundColor = UIColor.systemGray6
        tblView.tableFooterView = footerview
        tblView.cr.addHeadRefresh { [weak self] in
            self?.dataRest()
        }
        
        self.dataRest()
    }
    
    func dataRest() {
        pageNum = 1
        pageEnd = false
        requestMyBlockList()
        if listData.count > 0 {
            self.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    func addData() {
        requestMyBlockList()
    }
    func requestMyBlockList() {
        if pageEnd == true {
            return
        }
        
        var param:[String:Any] = [:]
        param["user_id"] = ShareData.ins.myId
        param["pageNum"] = pageNum
        
        ApiManager.ins.requestMyBlockList(param: param) { (response) in
            self.canRequest = true
            let result = response["result"].arrayValue
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                if self.pageNum == 1 {
                    self.listData = result
                }
                else if result.isEmpty == false {
                    self.listData.append(contentsOf: result)
                }
                
                if result.count == 0 {
                    self.pageEnd = true
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
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
    
    func requseDeleteBlockList(_ toUserId:String) {
        let param:[String:Any] = ["user_id":ShareData.ins.myId, "black_user_id": toUserId]
        ApiManager.ins.requestDeleteBlockList(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.dataRest()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
}

extension MyBlockListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyBlockListCell.identifier) as? MyBlockListCell else {
            return UITableViewCell()
        }
        
        let item = listData[indexPath.row]
        cell.configurationData(item)
        cell.onClickedClouser = { (item, action) -> Void in
            guard let item = item else {
                return
            }
            if action == 100 {
                let black_user_id = item["black_user_id"].stringValue
                self.requseDeleteBlockList(black_user_id)
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MyBlockListViewController: UIScrollViewDelegate {
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
