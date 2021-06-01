//
//  NoticeListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON

class NoticeListViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svContent: UIStackView!
    
    var listData:[JSON] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, NSLocalizedString("layout_txt23", comment: "공지사항"), #selector(actionNaviBack))
        requestNoticeList()
    }
    func requestNoticeList() {
        
        ApiManager.ins.requestNoticeList(param: ["user_id": ShareData.ins.myId, "forgn_lang": ShareData.ins.languageCode.uppercased()]) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            let result = response["result"].arrayValue
            if isSuccess == "01" {
                if result.count > 0 {
                    self.listData = result
                    self.scrollView.isHidden = false
                    self.reloadData()
                }
                else {
                    self.scrollView.isHidden = true
                }
            }
            else {
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    func reloadData() {
        for subview in svContent.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for item in listData {
            let cell = Bundle.main.loadNibNamed("NoticeCellView", owner: nil, options: nil)?.first as! NoticeCellView
            svContent.addArrangedSubview(cell)
            cell.configurationData(item)
        }
        let lbTmp = UILabel.init()
        lbTmp.text = ""
        svContent.addArrangedSubview(lbTmp)
        lbTmp.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        lbTmp.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
    }
}
