//
//  PointHistoryViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/15.
//

import UIKit
import SwiftyJSON

class PointHistoryCell: UITableViewCell {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


enum PointHistoryType {
    case point, star, exchange
    
    func displayName() ->String {
        if self == .point {
            return NSLocalizedString("activity_txt463", comment: "포인트 적립 소모내역")
        }
        else if self == .star {
            return NSLocalizedString("activity_txt514", comment: "별 적립 소모 내역")
        }
        else if self == .exchange {
            return NSLocalizedString("activity_txt347", comment: "별 환급 목록")
        }
        else {
           return ""
        }
    }
}

class PointHistoryViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    var type: PointHistoryType = .point
    var listData:[JSON] = []
    var pageNum:Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, type.displayName(), #selector(actionNaviBack))
        self.tblView.tableFooterView = UIView()
        requestPointList()
    }
    
    
    func requestPointList() {
        
        if type == .point {
            let param = ["user_id":ShareData.ins.myId]
            ApiManager.ins.requestMyPList(param: param) { res in
                let isSuccess = res["isSuccess"].stringValue
                let result = res["result"].arrayValue
                if isSuccess == "01" {
                    
                    for item in result {
                        let user_point_type = item["user_point_type"].stringValue
                        let to_user_id = item["to_user_id"].stringValue
                       
                        if "여" ==  ShareData.ins.mySex.rawValue {
                            if user_point_type == "영상신청"
                                || user_point_type == "영상시작기본"
                                || user_point_type == "영상종료"
                                || user_point_type == "별선물" {
                                continue
                            }
                        }
                        if "쪽지" == user_point_type && ShareData.ins.myId == to_user_id {
                            continue
                        }
                        self.listData.append(item)
                    }
                    
                    if self.listData.isEmpty == false {
                        self.tblView.isHidden = false
                        self.tblView.reloadData()
                    }
                    else {
                        self.tblView.isHidden = true
                    }
                }
                else {
                    self.tblView.isHidden = true
                    self.showErrorToast(res)
                }
            } failure: { error in
                self.showErrorToast(error)
            }
        }
        else if type == .star {
            //api/talk/getMyRList.json
            let param = ["user_id":ShareData.ins.myId]
            ApiManager.ins.requestMyRList(param: param) { res in
                let isSuccess = res["isSuccess"].stringValue
                let result = res["result"].arrayValue
                if isSuccess == "01" {
                    
                    for item in result {
                        let user_r_type = item["user_r_type"].stringValue
                        if "남" ==  ShareData.ins.mySex.rawValue
                            && ("영상적립" == user_r_type || "별선물" == user_r_type) {
                            continue
                        }
                        self.listData.append(item)
                    }
                    
                    if self.listData.isEmpty == false {
                        self.tblView.isHidden = false
                        self.tblView.reloadData()
                    }
                    else {
                        self.tblView.isHidden = true
                    }
                }
                else {
                    self.tblView.isHidden = true
                    self.showErrorToast(res)
                }
            } failure: { error in
                self.showErrorToast(error)
            }
        }
        else if type == .exchange {
            //api/talk/myMoneyList.json
            let param:[String:Any] = ["user_id":ShareData.ins.myId, "pageNum":pageNum]
            
            ApiManager.ins.requestMyMoneyList(param: param) { res in
                let isSuccess = res["isSuccess"].stringValue
                let result = res["result"].arrayValue
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
                    self.tblView.isHidden = true
                    self.showErrorToast(res)
                }
            } failure: { error in
                self.showErrorToast(error)
            }
        }
    }
    
    func addData() {
        if type == .exchange {
            self.requestPointList()
        }
    }
}

extension PointHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PointHistoryCell") as? PointHistoryCell else {
            return UITableViewCell()
        }

        let item = listData[indexPath.row]
        
        if type == .point {
            let user_memo = item["user_memo"].stringValue  //" : "별선물차감",
//            let user_point_type = item["user_point_type"].stringValue  //" : "별선물",
//            let to_user_id = item["to_user_id"].stringValue  //" : "a52fd10c131f149663a64ab074d5b44b",
            let reg_date = item["reg_date"].stringValue  //" : "2021-05-10 02:14:06",
            let user_point = item["user_point"].stringValue  //" : 100,
            let user_name = item["user_name"].stringValue  //" : "오늘은너야1",
//            let to_user_name = item["to_user_name"].stringValue  //" : "오늘의주인공은나아2",
//            let user_id = item["user_id"].stringValue  //" : "c4f3f037ff94f95fe144fc9aed76f0b6",
//            let seq = item["seq"].stringValue  //" : 64833
            
            let point = "\(user_point)".addComma()
            let msg = "\(user_memo)"+" (\(user_name)) 포인트\(point)개"
            
            cell.lbTitle.text = msg
            cell.lbSubTitle.text = reg_date
        }
        else if type == .star {
//            let send_id = item["send_id"].stringValue  // "c4f3f037ff94f95fe144fc9aed76f0b6",
            let reg_date = item["reg_date"].stringValue  // "2021-05-10 02:00:07",
            let user_r_type = item["user_r_type"].stringValue  // "별선물",
            let send_name = item["send_name"].stringValue  // "오늘은너야1",
            let user_memo = item["user_memo"].stringValue  // "별선물적립",
//            let user_id = item["user_id"].stringValue  // "a52fd10c131f149663a64ab074d5b44b",
            let user_name = item["user_name"].stringValue  // "오늘의주인공은나아2",
//            let seq = item["seq"].stringValue  // 3504,
            let user_r = item["user_r"].stringValue  // 40
            
            let point = "\(user_r)".addComma()
            var msg = "\(user_memo)"+" (\(send_name)) 별\(point)개"
            
            if "여" == ShareData.ins.mySex.rawValue {
                if user_r_type == "영상적립"
                    || user_r_type == "별선물"
                    || user_r_type == "유료채팅"
                    || user_r_type == "사진보기" {
                    
                    msg = "\(user_memo)"+" (\(user_name)) 별\(point)개"
                }
            }
            else if "남" ==  ShareData.ins.mySex.rawValue && "유료채팅" == user_r_type {
                msg = "\(user_memo)"+" (\(user_name)) 별\(point)개"
            }
            cell.lbTitle.text = msg
            cell.lbSubTitle.text = "\(reg_date)"
        }
        else {
//            let seq = item["seq"].stringValue  // 8,
//            let page = item["page"].stringValue  // 1,
            let stat = item["stat"].stringValue  // "N",
            let bank = item["bank"].stringValue  // "광주은행[34]",
//            let rownum = item["rownum"].stringValue  // 1,
            let reg_date = item["reg_date"].stringValue  // "2021-05-11 09:26:37",
//            let bank_num = item["bank_num"].stringValue  // "8850505",
            let out_point = item["out_point"].stringValue  // "360",
//            let end_date = item["end_date"].stringValue  // null,
            let bank_name = item["bank_name"].stringValue  // "김개똥"

            var endTxt = ""
            if stat == "Y" {
               endTxt = NSLocalizedString("activity_txt34", comment: "입금 완료")
            }
            else {
                endTxt = NSLocalizedString("activity_txt35", comment: "입금 대기중")
            }
        
            let msg = "\(Bank.localizedString(bank)) (\(bank_name))\n\(NSLocalizedString("activity_txt36", comment:"환급신청 금액:"))" + String(format: NSLocalizedString("activity_txt37", comment: ""), out_point.addComma(), out_point.addComma())
            cell.lbTitle.text = msg
            
            let date = NSLocalizedString("activity_txt39", comment:"신청일:") + "\(reg_date), \(endTxt)\n" + NSLocalizedString("activity_txt40", comment: "실 입금은 수수료등을 뺀 금액을 입금하여 드립니다. 약관 참조")
            cell.lbSubTitle.text = date
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension PointHistoryViewController: UIScrollViewDelegate {
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
