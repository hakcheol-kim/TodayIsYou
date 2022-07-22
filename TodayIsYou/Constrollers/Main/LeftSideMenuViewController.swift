//
//  LeftSideMenuViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/17.
//

import UIKit
import UIImageViewAlignedSwift
class LeftSideMenuCell: UITableViewCell {
    @IBOutlet weak var ivIcon: UIImageViewAligned!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configuration(_ data:[String:String]) {
        if let title = data["title"] {
            self.lbTitle.text = title
        }
        if let imgName = data["imgName"] {
            ivIcon.image = UIImage(systemName: imgName)
        }
    }
}

class LeftSideMenuViewController: UIViewController {

    @IBOutlet weak var heightHeight: NSLayoutConstraint!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var lbUserInfo: UILabel!
    @IBOutlet weak var ivSubscripion: UIImageView!
    
    let listData:[[String:String]] = [["title": NSLocalizedString("point_activity01", comment: "포인트 충전"), "imgName": "pesetasign.circle.fill"],
                                      ["title": NSLocalizedString("layout_txt23", comment: "공지사항"), "imgName": "bell.circle.fill"],
                                      ["title": NSLocalizedString("activity_txt291", comment: "찜 목록"), "imgName": "arrow.up.left.circle.fill"],
                                      ["title": NSLocalizedString("activity_txt165", comment: "차단목록"), "imgName": "xmark.circle.fill"],
                                      ["title": NSLocalizedString("activity_txt284", comment: "사용자 접속목록"), "imgName": "person.circle.fill"]]
//                                      ["title": NSLocalizedString("log_out", comment: "로그아웃"), "imgName": "arrow.backward.square.fill"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        self.tblView.tableHeaderView = headerView
        self.tblView.tableFooterView = UIView.init()
//        if let img = UIImage(named: "img_back2.jpg") {
//            headerView.backgroundColor = UIColor(patternImage: img)
//        }
//        headerView.addGradient(RGB(230, 50, 70), end: UIColor.white, sPoint: CGPoint(x: 1, y:0), ePoint: CGPoint(x: 1, y: 1))
        ivProfile.clipsToBounds = true
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        ivSubscripion.layer.cornerRadius = 4.0
        ivSubscripion.clipsToBounds = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestMyInfo()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateHeaderView()
        tblView.reloadData()
    }
    
    func updateHeaderView() {
        guard let headerView = tblView.tableHeaderView else {
            return
        }
//        lbNickName.translatesAutoresizingMaskIntoConstraints = false
//        let fitHeight = lbNickName.sizeThatFits(CGSize(width: lbNickName.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
//        heightHeight.constant = fitHeight

        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.size.width, height: height)
    }
    func decorationUi() {
        ivProfile.clipsToBounds = true
        lbNickName.text = ""
        lbUserInfo.text = ""
        
        var info = ""
        if let userName = ShareData.ins.dfsGet(DfsKey.userName) as? String {
            info = userName
        }
        if let age = ShareData.ins.dfsGet(DfsKey.userAge) as? String {
            info.append(", \(Age.localizedString(age))")
        }
        
        info.append(", \(Gender.localizedString(ShareData.ins.mySex.rawValue))")
        lbNickName.text = info

        
        let pPoint: String = "\(ShareData.ins.myPoint?.intValue ?? 0)".addComma()+"P"
        let sp = ShareData.ins.dfsGet(DfsKey.userR) as? NSNumber
        
        var sPoint = "0S"
        if let sp = sp?.stringValue {
            sPoint = "\(sp.addComma())S"
        }
        let result = "<span style='color:rgb(255,0,0); font-size:16px;'>\(pPoint) <span style='color:rgb(0,0,255);'>\(sPoint)</span></span>"
        
        lbUserInfo.attributedText = try? NSAttributedString.init(htmlString: result)
        
        ivProfile.image = Gender.defaultImg(ShareData.ins.mySex.rawValue)
        if let userImg = ShareData.ins.dfsGet(DfsKey.userImg) as? String, let url = Utility.thumbnailUrl(ShareData.ins.myId, userImg) {
            ivProfile.setImageCache(url)
            ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        }
        self.updateFocusIfNeeded()
    }
    
    func requestMyInfo() {
        let param = ["app_type": appType, "user_id":ShareData.ins.myId]
        ApiManager.ins.requestUerInfo(param: param) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            if isSuccess == "01" {
                ShareData.ins.setUserInfo(response)
                self.decorationUi()
                print("myinfo : \(response)")
                self.tblView.reloadData()
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
}

extension LeftSideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeftSideMenuCell", for: indexPath) as? LeftSideMenuCell else {
            return UITableViewCell()
        }
        cell.configuration(listData[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.dismiss(animated: true) {
            switch indexPath.row {
            case 0:
                let vc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 1:
                let vc = NoticeListViewController.instantiateFromStoryboard(.main)!
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 2:
                let vc = MyFrendsListViewController .instantiateFromStoryboard(.main)!
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 3:
                let vc = MyBlockListViewController.instantiateFromStoryboard(.main)!
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 4:
                let vc = ConnectUserListViewController.instantiateFromStoryboard(.main)!
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 5:
                CAlertViewController.show(type: .alert, title: "log_out".localized, message: "log_out_msg".localized, actions: [.cancel, .ok]) { (vcs, selItem, action) in
                    vcs.dismiss(animated: true, completion: nil)
                    
                    if action == 1 {
                        AppsFlyerEvent.addEventLog(.logout, ["user_id": ShareData.ins.myId, "user_name":ShareData.ins.myName, "user_sex":ShareData.ins.mySex.rawValue])
                        ShareData.ins.dfsRemove(DfsKey.userId)
//                        KeychainItem.deleteUserIdentifierFromKeychain()
                        appDelegate.callLoginVC()
                    }
                }
                break
            default:
                break
            }
        }
    }
}
