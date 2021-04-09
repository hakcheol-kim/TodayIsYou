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

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var lbUserInfo: UILabel!
    
    let listData:[[String:String]] = [["title": "포인트 충전", "imgName": "pesetasign.circle"],
                                      ["title": "공지사항", "imgName": "bell"],
                                      ["title": "찜 목록", "imgName": "hand.tap"],
                                      ["title": "차단 목록", "imgName": "xmark.circle"],
                                      ["title": "사용자 접속목록", "imgName": "person"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        self.tblView.tableHeaderView = headerView
        self.tblView.tableFooterView = UIView.init()
//        if let img = UIImage(named: "img_back2.jpg") {
//            headerView.backgroundColor = UIColor(patternImage: img)
//        }
        headerView.addGradient(RGB(230, 50, 70), end: UIColor.white, sPoint: CGPoint(x: 1, y:0), ePoint: CGPoint(x: 1, y: 1))
        headerView.clipsToBounds = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        ivProfile.clipsToBounds = true
        
        if let userName = ShareData.ins.dfsObjectForKey(DfsKey.userName) {
            let gender = ShareData.ins.mySex.rawValue
            lbNickName.text = "\(userName), \(gender)"
        }
        
        
        
        let pPoint: String = "\(ShareData.ins.userPoint?.intValue ?? 0)".addComma()+"P"
        let sp = ShareData.ins.dfsObjectForKey(DfsKey.userR) as? NSNumber
        
        var sPoint = "0S"
        if let sp = sp?.stringValue {
            sPoint = "\(sp.addComma())S"
        }
        let result = "<span style='color:rgb(255,0,0); font-size:16px;'>\(pPoint) <span style='color:rgb(0,0,255);'>\(sPoint)</span></span>"
        
        lbUserInfo.attributedText = try? NSAttributedString.init(htmlString: result)
        
        ivProfile.image = Gender.defaultImg(ShareData.ins.mySex.rawValue)
        if let userImg = ShareData.ins.dfsObjectForKey(DfsKey.userImg) as? String, let url = Utility.thumbnailUrl(ShareData.ins.myId, userImg) {
            ivProfile.setImageCache(url: url, placeholderImgName: nil)
            ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tblView.reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = tblView.tableHeaderView else {
            return
        }
        
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.size.width, height: height)
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
                let vc = PointChargeViewController.instantiateFromStoryboard(.main)!
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 1:
                let vc = NoticeListViewController.instantiateFromStoryboard(.main)!
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 2:
                let vc = MyFrendsListViewController .instantiateFromStoryboard(.main)!
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 3:
                let vc = MyBlockListViewController.instantiateFromStoryboard(.main)!
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 4:
                let vc = ConnectUserListViewController.instantiateFromStoryboard(.main)!
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            default:
                break
            }
        }
    }
}
