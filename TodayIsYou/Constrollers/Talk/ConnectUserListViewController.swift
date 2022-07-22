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
            
            if let day = comps.day, day > 0 {
                tStr = String(format: "%ld%@", day, NSLocalizedString("activity_txt24", comment: "일전"))
            }
            else if let hour = comps.hour, hour > 0 {
                tStr = String(format: "%02ld%@ %02ld%@", hour, NSLocalizedString("activity_txt66", comment: "시간"), (comps.minute ?? 0), NSLocalizedString("activity_txt30", comment: "분전"))
            }
            else if let minute = comps.minute, minute > 0 {
                tStr = String(format: "%02ld%@ %02ld%@", minute, NSLocalizedString("activity_txt27", comment: "분"), (comps.second ?? 0), NSLocalizedString("activity_txt28", comment: "초전"))
            }
            else if let second = comps.second, second > 0 {
                tStr = String(format: "%02ld%@", second, NSLocalizedString("activity_txt28", comment: "초전"))
            }
        }
        result.append(tStr)
        let attr = NSMutableAttributedString.init(string: result)
//        attr.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSMakeRange(0, user_name.length))
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: lbTitle.font.pointSize, weight: .medium), range: NSMakeRange(0, user_name.length))
        lbTitle.attributedText = attr
        
        let userSex = (Gender.localizedString(user_sex))
        let result2 = "\(Age.localizedString(user_age)), \(userSex), \(Area.localizedString( user_area))"
        let attr2 = NSMutableAttributedString.init(string: result2)
        if user_sex == "남" {
            attr2.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: (result2 as NSString).range(of: userSex))
        }
        else {
            attr2.addAttribute(.foregroundColor, value: UIColor.appColor(.redLight), range: (result2 as NSString).range(of: userSex))
        }
        lbSubTitle.attributedText = attr2
        
        ivProfile.image = Gender.defaultImgSquare(user_sex)
        if let url = Utility.thumbnailUrl(user_id, user_img) {
            ivProfile.setImageCache(url)
        }
    }
}

class ConnectUserListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnGender: CButton!
    @IBOutlet weak var tfGender: CTextField!
    @IBOutlet weak var btnState: CButton!
    @IBOutlet weak var tfState: CTextField!
    @IBOutlet weak var lbNotice: UILabel!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:String = "성별" {
        didSet {
            if searchSex == "남" {
                tfGender.text = NSLocalizedString("root_display_txt21", comment: "남")
            }
            else if searchSex == "여" {
                tfGender.text = NSLocalizedString("root_display_txt20", comment: "여")
            }
            else {
                tfGender.text = NSLocalizedString("activity_txt286", comment: "성별")
            }
        }
    }
    var searchState: String = "접속" {
        didSet {
            if searchState == "ON" {
                tfState.text = searchState
            }
            else if searchState == "OFF" {
                tfState.text = searchState
            }
            else {
                tfState.text = NSLocalizedString("layout_txt42", comment: "접속")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        CNavigationBar.drawBackButton(self, NSLocalizedString("activity_txt284", comment: "유저접속목록"),  #selector(actionNaviBack))
        self.tblView.tableFooterView = UIView.init()
        self.searchSex = ShareData.ins.mySex.transGender().rawValue
        self.searchState = "접속"
        
        self.dataRest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        param["user_id"] = ShareData.ins.myId
        param["pageNum"] = pageNum
        
        if searchSex == "성별" {
            param["search_sex"] = ""
        }
        else {
            param["search_sex"] = searchSex
        }
        if searchState == "접속" {
            param["search_onoff"] = ""
        }
        else {
            param["search_onoff"] = searchState
        }
        
        ApiManager.ins.requestGetUserList(param: param) { (resonse) in
            self.canRequest = true
            let result = resonse["result"].arrayValue
            let isSuccess = resonse["isSuccess"].stringValue
            if isSuccess == "01" {
                if result.count == 0 {
                    self.pageEnd = true
                    self.listData = result
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
        if sender == btnGender {
            var list = [String]()
            list.append(NSLocalizedString("activity_txt286", comment: "성별"))
            list.append(NSLocalizedString("root_display_txt21", comment: "남"))
            list.append(NSLocalizedString("root_display_txt20", comment: "여"))
            
            let vc = PopupListViewController.initWithType(.normal, NSLocalizedString("join_activity07", comment:"성별을 선택해주세요."), list , nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? String else {
                    return
                }
                if (index == 0) {
                    self.searchSex = "성별"
                }
                else if index == 1 {
                    self.searchSex = "남"
                }
                else {
                    self.searchSex = "여"
                }
                
                self.dataRest()
            }
            self.presentPanModal(vc)
        }
        else if sender == btnState {
            var list = [String]()
            list.append(NSLocalizedString("layout_txt42", comment: "접속"))
            list.append("ON")
            list.append("OFF")
            
            let vc = PopupListViewController.initWithType(.normal, nil, list, nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? String else {
                    return
                }
                
                if (index == 0) {
                    self.searchState = "접속"
                }
                else if index == 1 {
                    self.searchState = "ON"
                }
                else {
                    self.searchState = "OFF"
                }
                self.dataRest()
            }
            self.presentPanModal(vc)
        }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        if ShareData.ins.isReview == false {
            let vc = RankDetailViewController.instantiateFromStoryboard(.main)!
            vc.passData = item
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
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
