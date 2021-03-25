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
                guard let vc = self.storyboard?.instantiateViewController(identifier: "PointChargeViewController") as? PointChargeViewController else {
                    return
                }
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 1:
                guard let vc = self.storyboard?.instantiateViewController(identifier: "NoticeListViewController") as? NoticeListViewController else {
                    return
                }
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 2:
                guard let vc = self.storyboard?.instantiateViewController(identifier: "MyFrendsListViewController") as? MyFrendsListViewController else {
                    return
                }
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 3:
                guard let vc = self.storyboard?.instantiateViewController(identifier: "MyBlockListViewController") as? MyBlockListViewController else {
                    return
                }
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            case 4:
                guard let vc = self.storyboard?.instantiateViewController(identifier: "ConnectUserListViewController") as? ConnectUserListViewController else {
                    return
                }
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
                break
            default:
                break
            }
        }
    }
}
