//
//  PointPurchaseViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import StoreKit
class PointPurchaseViewController: BaseViewController {
    @IBOutlet weak var lbPointTitle: Clabel!
    @IBOutlet var arrBtnPoint: [CButton]!
    @IBOutlet weak var btnContactus: CButton!
    @IBOutlet weak var lbCurPoint: UILabel!
    var points = [PointModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPManager.shared.fetchProductus()
        
        arrBtnPoint = arrBtnPoint.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        
        for btn in arrBtnPoint {
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        refreshUi()
        CNavigationBar.drawBackButton(self, "point_activity01".localized, #selector(actionNaviBack))
        lbPointTitle.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let myPoint = ShareData.ins.dfsGet(DfsKey.userPoint) as? NSNumber {
            lbCurPoint.text = "\(myPoint.stringValue.addComma()) Point"
        }
    }
    
    func refreshUi() {
        if let myPoint = ShareData.ins.myPoint {
            lbCurPoint.text = "\(myPoint.stringValue.addComma()) Point"
        }
    }
    
    func requestPayloadId(_ product:Product) {
        let buyKey = product.severProductId()
        let param = ["user_id":ShareData.ins.myId, "buy_key":buyKey]
        ApiManager.ins.requestSaveInAppPayload(param: param) { res in
            let isSuccess = res["isSuccess"].stringValue
            let payload = res["payload"].stringValue
            let buy_key = res["buy_key"].stringValue
            if isSuccess == "01" && payload.isEmpty == false, buy_key.isEmpty == false {
                self.inAppPayment(product: product, payload, buy_key: buy_key)
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func inAppPayment(product:Product, _ payload:String, buy_key:String) {
        
        IAPManager.shared.purchage(product: product) {[weak self] result in
            guard let transactionId = result["transactionId"],  let receipt = result["receipt"] else {
                print("error: transactionIdentifiy, receipt empty")
                return
            }
            
            let productId = product.severProductId()
            var param = [String:Any]()
            param["user_id"] = ShareData.ins.myId
            param["productId"] = productId  //삼품코드
            param["app_type"] = appType //어플종류
            param["point_key"] = "GPA.\(transactionId)" //주문번호 아이폰은 GPA. 붙인다 서버 구분하기 위해
            param["developerPayload"] = payload //서버에서 생성한 payload sequence
            param["purchaseToken"] = receipt
            param["packageName"] = Bundle.main.bundleIdentifier
            
            self?.requestSaveInAppPoint(param)
        }
    }
    
    func requestSaveInAppPoint(_ param:[String:Any]) {
        ApiManager.ins.requestSaveAppPoint(param: param) { res in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.getUserInfo()
                print("결제 성공!!")
            }
            else {
                print("결제오류!!")
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func getUserInfo() {
        ApiManager.ins.requestUerInfo(param: ["user_id":ShareData.ins.myId]) { res in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                ShareData.ins.setUserInfo(res)
                self.refreshUi()
            }
        } failure: { error in
            self.showErrorToast(error)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnContactus {
            let vc = ContactusViewController.instantiateFromStoryboard(.main)!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if arrBtnPoint.contains(sender as! CButton) {
            switch sender.tag {
            case 0:
                self.requestPayloadId(.point_000)
                break
            case 1:
                self.requestPayloadId(.point_001)
                break
            case 2:
                self.requestPayloadId(.point_002)
                break
            case 3:
                self.requestPayloadId(.point_003)
                break
            case 4:
                self.requestPayloadId(.point_004)
                break
            case 5:
                self.requestPayloadId(.point_005)
                break
            default:
                break
            }
        }
    }
}
