//
//  PictureManagerListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/28.
//

import UIKit
import SwiftDate

class PictureManagerListCell: UITableViewCell {
    @IBOutlet weak var lbRegiDate: UILabel!
    @IBOutlet weak var ivThumb: UIImageView!
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
    
    func configurationData(_ model: PictureManagementMeModel) {
        print(model)
//        {"seq":"22","user_id":"a52fd10c131f149663a64ab074d5b44b","user_name":"\ub3c4\ub2f4\uc774","pb_url":"http:\/\/todayisyou.co.kr:8080\/upload\/talk\/3cef091917e09e9a7f8010ce6c8d89f4\/thum\/thum_20220302044824608.jpg","bp_subject":"\uc81c\ubaa911","bp_point":"120","bp_adult":"Y","bp_type":"P","bp_inspect":"1","sum_bo_point":"120","bp_reg_date":"2022-02-25 16:59:40.000"}
        
        let date = model.bp_reg_date.toDate(style: .custom("yyyy-MM-dd HH:mm:ss.SSS"))
        lbRegiDate.text = ""
        if let dateStr = date?.toString(.custom("yyyy.MM.dd HH.mm")) {
            lbRegiDate.text = "[\(NSLocalizedString("picture_regist_date", comment: "")) \(dateStr)]"
        }
        ivThumb.image = UIImage(systemName: "person.fill")
        ivThumb.contentMode = .scaleAspectFill
        if model.pb_url.length > 0 {
            ivThumb.setImageCache(model.pb_url, nil)
        }
        //bp_inspect    화보상태    0: 승인대기 / 1: 승인완료 / 2 : 승인반려
        if model.bp_inspect == 0 {
            btnState.backgroundColor = .appColor(.blueLight)
            btnState.setTitle(NSLocalizedString("picture_setting_state2", comment: ""), for: .normal)
        }
        else if model.bp_inspect == 1 {
            btnState.backgroundColor = .appColor(.redLight)
            btnState.setTitle(NSLocalizedString("picture_setting_state1", comment: ""), for: .normal)
        }
        else {
            btnState.backgroundColor = .appColor(.gray102)
            btnState.setTitle(NSLocalizedString("picture_setting_state3", comment: ""), for: .normal)
        }
        let total = String(format: NSLocalizedString("picture_setting_total", comment: ""), "\(model.sum_bo_point)".addComma())
        lbPurchaseInfo.text = "\(NSLocalizedString("picture_setting_amount", comment: "")) : " + "\(model.bp_point)".addComma() + NSLocalizedString("picture_setting_point", comment: "") + total
        
        lbDes.text = model.bp_subject
    }
}
class PictureManagerListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    
    
    var listData = [PictureManagementMeModel]()
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
        self.currentPage = 1
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
        param["my_pic"] = "my_data"
        
        weak var weakSelf = self
        ApiClient.ins.request(.fetchMyPictureList(param), PictureManagementMeResModel.self) { result in
            guard let self = weakSelf else { return }
            
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

extension PictureManagerListViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PictureManagerListCell") as? PictureManagerListCell else {
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
