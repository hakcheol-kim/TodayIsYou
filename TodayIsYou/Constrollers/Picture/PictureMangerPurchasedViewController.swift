//
//  PictureManagerListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/28.
//

import UIKit
import SwiftDate
import UIImageViewAlignedSwift

class PictureMangerPurchasedListCell: UITableViewCell {
    @IBOutlet weak var lbRegiDate: UILabel!
    @IBOutlet weak var ivThumb: UIImageViewAligned!
    @IBOutlet weak var btnState: CButton!
    @IBOutlet weak var lbDes: UILabel!
    @IBOutlet weak var lbPurchaseInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ivThumb.layer.cornerRadius = 8
        self.ivThumb.clipsToBounds = true
        self.ivThumb.layer.borderColor = UIColor.appColor(.gray221).cgColor
        self.ivThumb.layer.borderWidth = 0.5
    }
    
    func configurationData(_ model: PicturePurchasedModel) {
        if model.pb_url.length > 0 {
            ivThumb.setImageCache(model.pb_url, nil)
        }
        var strDate = ""
        if let date = model.bo_reg_date.toDate("yyyy-MM-dd HH:mm:ss.SSS") {
            strDate = date.toString(.custom("yyyy.MM.dd HH:mm"))
        }
        
        btnState.isHidden = true
        
        lbRegiDate.text = "["+NSLocalizedString("picture_earning_buy_date", comment: "구매일")+" \(strDate)]"
        lbDes.text = model.bp_subject
        lbPurchaseInfo.text = NSLocalizedString("picture_earning_seller", comment: "판매자") + ": \(model.user_name), " + NSLocalizedString("picture_setting_amount", comment: "금액") + ": " + "\(model.bo_point)".addComma()+NSLocalizedString("picture_setting_point", comment: "")
        
        print(model)
    }
}
class PictureMangerPurchasedViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    
    
    var listData = [PicturePurchasedModel]()
    var canRequest: Bool = true
    private var currentPage: Int = 1
    private let pageCnt = 30
    private var pageEnd: Bool = false
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataRest()
    }
    private func initUI() {
        tblView.estimatedRowHeight = 34
        tblView.rowHeight = UITableView.automaticDimension
    }
    func dataRest() {
        currentPage = 1
        pageEnd = false
        requestData()
    }
    func addData() {
        requestData()
    }
    
    private func requestData() {
        if pageEnd { return }
        var param = [String : Any]()
        param["user_id"] = ShareData.ins.myId
        param["current_page"] = currentPage
        param["page_cnt"] = pageCnt
        
        ApiClient.ins.request(.purchasedPictureList(param), PicturePurchasedResModel.self) { result in
            if result.code == "000" {
                if result.bb_list.count > 0 {
                    if self.currentPage == 1 {
                        self.listData = result.bb_list
                    }
                    else {
                        self.listData.append(contentsOf: result.bb_list)
                    }
                    self.tblView.reloadData()
                }
                else {
                    //001 화제정보 없음
                    self.pageEnd = true
                }
                self.currentPage += 1
                if (self.listData.isEmpty) {
                    self.tblView.isHidden = true
                }
            }
            else {
                if (self.listData.isEmpty) {
                    self.tblView.isHidden = true
                }
            }
        } failure: { error in
            self.showErrorToast(error?.errorDescription)
        }
    }
}

extension PictureMangerPurchasedViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PictureMangerPurchasedListCell") as? PictureMangerPurchasedListCell else {
            return UITableViewCell()
        }
        let model = listData[indexPath.row]
        cell.configurationData(model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let model = listData[indexPath.row]
        let detailViewModel = PictureDetailViewModel(seq: model.seq, bpUserId: model.user_id)
        let vc = PictureDetailViewController.initWithViewModel(detailViewModel)
        appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100

        if velocityY < 0 && offsetY > contentH && canRequest == true {
            canRequest = false
            addData()
        }
    }
}
