//
//  PictureManagerListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/28.
//

import UIKit
import SwiftDate
import Mantis

class PictureManagerEarningListCell: UITableViewCell {
    @IBOutlet weak var lbRegiDate: UILabel!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbDes: UILabel!
    @IBOutlet weak var lbPurchaseInfo: UILabel!
    @IBOutlet weak var lbPhoint: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ivThumb.layer.cornerRadius = 8
        self.ivThumb.clipsToBounds = true
        self.ivThumb.layer.borderColor = UIColor.appColor(.gray221).cgColor
        self.ivThumb.layer.borderWidth = 0.5
    }
    
    func configurationData(_ model: PictureEarningModel) {
        ivThumb.contentMode = .scaleAspectFill
        ivThumb.image = UIImage(named: "person.fill")
        if model.pb_url.length > 0 {
            ivThumb.setImageCache(model.pb_url, nil)
        }
        var strDate = ""
        if let date = model.bo_reg_date.toDate("yyyy-MM-dd HH:mm:ss.SSS") {
            strDate = date.toString(.custom("yyyy.MM.dd HH:mm"))
        }
        
        lbRegiDate.text = "["+NSLocalizedString("picture_earning_buy_date", comment: "구매일")+" \(strDate)]"
        lbDes.text = model.bp_subject
        lbPurchaseInfo.text = NSLocalizedString("picture_earning_buyer", comment: "구매자") + "\(model.user_name)"
        lbPhoint.text = "+" + "\(model.bo_point)".addComma()
        
        print(model)
    }
}

class PictureMangerEarningViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet var headerview: UIView!
    @IBOutlet weak var btnMonth: CButton!
    @IBOutlet weak var lbMonth: UILabel!
    @IBOutlet weak var btnSearch: CButton!
    @IBOutlet weak var tfStart: CTextField!
    @IBOutlet weak var tfEnd: CTextField!
    @IBOutlet weak var lbTotalCnt: UILabel!
    @IBOutlet weak var lbTotalEarning: UILabel!
    @IBOutlet weak var topTblViewSafety: NSLayoutConstraint!
    @IBOutlet weak var topHeaderView: NSLayoutConstraint!
    @IBOutlet weak var monthPickView: CView!
    @IBOutlet weak var btnMonth3: CButton!
    @IBOutlet weak var btnMonth6: CButton!
    @IBOutlet weak var btnMonth12: CButton!
    
    var isHiddenMonthPopup: Bool! {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                self.monthPickView.isHidden = self.isHiddenMonthPopup
            } completion: { finish in
                
            }
        }
    }
    var startDate: Date!
    var endDate: Date!
    
    var listData = [PictureEarningModel]()
    var totalCnt = 0
    var totalSum = 0
    var canRequest: Bool = true
    private var currentPage: Int = 1
    private let pageCnt = 30
    private var pageEnd: Bool = false
    let korea = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.koreanSouthKorea)
    private var hitCnt = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        let today = DateInRegion(Date(), region: korea)
        self.endDate = today.date
        self.startDate = today.dateByAdding(-1, .month).date
        
        tfStart.text = startDate.toString(.custom("yyyy-MM-dd"))
        tfEnd.text = endDate.toString(.custom("yyyy-MM-dd"))
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(CNotiName.hitTest), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataRest()
    }
    private func initUI() {
        tblView.estimatedRowHeight = 34
        tblView.rowHeight = UITableView.automaticDimension
        
        lbMonth.text = String(format: NSLocalizedString("picture_earning_month", comment: ""), "1")
        btnMonth3.setTitle(String(format: NSLocalizedString("picture_earning_month", comment: ""), "3"), for: .normal)
        btnMonth6.setTitle(String(format: NSLocalizedString("picture_earning_month", comment: ""), "6"), for: .normal)
        btnMonth12.setTitle(String(format: NSLocalizedString("picture_earning_month", comment: ""), "12"), for: .normal)
        
        self.view.addSubview(monthPickView)
        monthPickView.translatesAutoresizingMaskIntoConstraints = false
        monthPickView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8).isActive = true
        monthPickView.topAnchor.constraint(equalTo: btnMonth.bottomAnchor, constant: 8).isActive = true
        monthPickView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        self.isHiddenMonthPopup = true
        lbTotalCnt.text = NSLocalizedString("picture_earning_total_sale_count", comment: "")
        lbTotalEarning.text = NSLocalizedString("picture_earning_total_sale_amount", comment: "")
    }
    private func configurationUI() {
        lbTotalCnt.text = NSLocalizedString("picture_earning_total_sale_count", comment: "") + " : " + "\(self.totalCnt)".addComma()
        lbTotalEarning.text = NSLocalizedString("picture_earning_total_sale_amount", comment: "") + " : " + "\(self.totalSum)".addComma()
    }
    
    @objc override func notificationHandler(_ notification: NSNotification) {
        if notification.name == Notification.Name(CNotiName.hitTest) {
            print("hittest")
            if hitCnt%2 == 0 && self.isHiddenMonthPopup == false {
                self.isHiddenMonthPopup = !isHiddenMonthPopup
            }
            hitCnt += 1
        }
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
        param["start_date"] = tfStart.text
        param["end_date"] = tfEnd.text

        ApiClient.ins.request(.pictureEarningList(param), PictureEarningResModel.self) { result in
            if result.code == "000" {
                if result.bb_list.count > 0 {
                    if self.currentPage == 1 {
                        self.listData = result.bb_list
                        self.totalCnt = result.bb_tcnt
                        self.totalSum = result.sum
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
                self.configurationUI()
            }
            else {
                if (self.listData.isEmpty) {
                    self.pageEnd = true
                    self.tblView.isHidden = true
                }
            }
        } failure: { error in
            self.showErrorToast(error?.errorDescription)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMonth {
            self.isHiddenMonthPopup = false
        }
        else if sender == btnMonth3 || sender == btnMonth6 || sender == btnMonth12 {
            var previous = -1
            if sender == btnMonth3 {
                lbMonth.text = String(format: NSLocalizedString("picture_earning_month", comment: ""), "3")
                previous = -3
            }
            else if sender == btnMonth6 {
                lbMonth.text = String(format: NSLocalizedString("picture_earning_month", comment: ""), "6")
                previous = -6
            }
            else if sender == btnMonth12 {
                previous = -12
                lbMonth.text = String(format: NSLocalizedString("picture_earning_month", comment: ""), "12")
            }
            
            let today = DateInRegion(Date(), region: korea)
            self.endDate = today.date
            self.startDate = today.dateByAdding(previous, .month).date
            
            tfStart.text = startDate.toString(.custom("yyyy-MM-dd"))
            tfEnd.text = endDate.toString(.custom("yyyy-MM-dd"))
            self.dataRest()
        }
        else if sender == btnSearch {
            self.dataRest()
        }
    }
}

extension PictureMangerEarningViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PictureManagerEarningListCell") as? PictureManagerEarningListCell else {
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
