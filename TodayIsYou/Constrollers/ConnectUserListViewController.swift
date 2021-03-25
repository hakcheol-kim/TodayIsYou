//
//  ConnectUserListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/17.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class ConnectUserCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageViewAligned!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configurationData(_ data: JSON?) {
        guard let data = data else {
            return
        }
//        let days = data["days"].intValue          // = 2;
//        let dong = data["dong"].stringValue          // = "<null>";
        let gu = data["gu"].stringValue          // = "<null>";
        let last_login = data["last_login"].stringValue          //" = "2021-03-15 03:29:37";
//        let locale = data["locale"].stringValue          // = "";
//        let logout_date = data["logout_date"].stringValue          //" = "<null>";
//        let seq = data["seq"].stringValue          // = 7151;
//        let si = data["si"].stringValue          // = "<null>";
//        let sms_auth = data["sms_auth"].stringValue          //" = N;
//        let times = data["times"].stringValue          // = "20:48:24";
        let user_age = data["user_age"].stringValue          //" = "70\Ub300";
        let user_area = data["user_area"].stringValue          //" = "\Uad11\Uc8fc";
//        let user_bbs_point = data["user_bbs_point"].stringValue          //" = 0;
        let user_id = data["user_id"].stringValue          //" = 29d52660b2254e597f8aa53f50fc2cd7;
        let user_img = data["user_img"].stringValue          //" = "";
//        let user_memo = data["user_memo"].stringValue          //" = "<null>";
        let user_name = data["user_name"].stringValue          //" = "\Uc0c1\Uc5b4";
//        let user_point = data["user_point"].intValue          //" = 100;
//        let user_r = data["user_r"].stringValue          //" = 0;
        let user_sex = data["user_sex"].stringValue          //" = "\Uc5ec";
        let user_status = data["user_status"].stringValue          //" = ON;
        
        
        let df = CDateFormatter.init()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss" // "2021-03-11 07:35:32
        var tStr = ""
        var result = "\(user_name), "
        if let regDate = df.date(from: last_login) {
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
        
        result.append(tStr)
        let attr = NSMutableAttributedString.init(string: result)
        attr.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSMakeRange(0, user_name.length))
        lbTitle.attributedText = attr
        
        let result2 = "\(user_age), \(user_sex), \(user_area)"
        let attr2 = NSMutableAttributedString.init(string: result2)
        attr2.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: (result2 as NSString).range(of: user_sex))
        lbSubTitle.attributedText = attr2
        
        ivProfile.image = Gender.defaultImg(user_sex)
        if let url = Utility.thumbnailUrl(user_id, user_img) {
            ivProfile.setImageCache(url: url, placeholderImgName: nil)
        }
    }
}

class ConnectUserListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnGender: CButton!
    @IBOutlet weak var btnState: CButton!
    @IBOutlet weak var lbNotice: UILabel!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.ins.mySex.transGender()
    var searchState: String = "" //접속: "", ON, OFF
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        CNavigationBar.drawBackButton(self, "사용자 접속목록",  #selector(actionNaviBack))
        self.tblView.tableFooterView = UIView.init()
        self.dataRest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        param["user_id"] = ShareData.ins.userId
        param["pageNum"] = pageNum
        param["search_sex"] = searchSex.rawValue
        param["search_onoff"] = searchState
        
        ApiManager.ins.requestGetUserList(param: param) { (resonse) in
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
    }
    
}
extension ConnectUserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectUserCell") as? ConnectUserCell else {
            return UITableViewCell()
        }
        
        if indexPath.row < listData.count {
            let item = listData[indexPath.row]
            cell.configurationData(item)
        }
        
        return cell
    }
}

extension ConnectUserListViewController: UIScrollViewDelegate {
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
