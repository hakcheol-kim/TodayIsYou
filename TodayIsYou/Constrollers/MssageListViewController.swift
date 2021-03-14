//
//  MssageListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON

class MssageListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnDelAll: UIButton!
    @IBOutlet weak var btnJim: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.instance.mySex.transGender()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
//        requestTalkList()
        if listData.count > 0 {
            self.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    func addData() {
//        requestTalkList()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
    }
    
}
extension MssageListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MessageTblCell") as? MessageTblCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("MessageTblCell", owner: nil, options: nil)?.first as? MessageTblCell
        }
        if indexPath.row < listData.count {
            let item = listData[indexPath.row]
            cell?.configurationData(item)
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension MssageListViewController: UIScrollViewDelegate {
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
