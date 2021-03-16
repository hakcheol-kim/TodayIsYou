//
//  PointGateViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/15.
//

import UIKit

class PointGateViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    
    let listData:[[String]] = [["포인트 내역", "별 내역", "환급 목록"],
                       ["환급 신청"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "별 환급신청", #selector(actionNaviBack))
    }
}
extension PointGateViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  listData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
            cell?.accessoryType = .disclosureIndicator
        }
        let title = listData[indexPath.section][indexPath.row]
        cell?.textLabel?.text = title
        return cell!
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "사용 내역"
        case 1:
            return "환급"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                guard let vc = self.storyboard?.instantiateViewController(identifier: "PointHistoryViewController") as? PointHistoryViewController else {
                    return
                }
                vc.type = .point
                self.navigationController?.pushViewController(vc, animated: true)
                return
            case 1:
                guard let vc = self.storyboard?.instantiateViewController(identifier: "PointHistoryViewController") as? PointHistoryViewController else {
                    return
                }
                vc.type = .star
                self.navigationController?.pushViewController(vc, animated: true)
                return
            case 2:
                guard let vc = self.storyboard?.instantiateViewController(identifier: "PointHistoryViewController") as? PointHistoryViewController else {
                    return
                }
                vc.type = .exchange
                self.navigationController?.pushViewController(vc, animated: true)
                return
            default:
                return
            }
        }
        else if indexPath.section == 1 {
            
        }
        
    }
}
