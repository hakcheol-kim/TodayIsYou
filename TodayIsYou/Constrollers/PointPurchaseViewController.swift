//
//  PointPurchaseViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import StoreKit
import SwiftyJSON

class PointPurchaseViewController: BaseViewController {
    @IBOutlet weak var lbPointTitle: Clabel!
    @IBOutlet var arrBtnPoint: [CButton]!
    @IBOutlet weak var btnContactus: CButton!
    @IBOutlet weak var lbCurPoint: UILabel!
    @IBOutlet var arrBtnSubscript: [CButton]!
    
    
    var points = [PointModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPManager.shared.fetchProductus()
        
        arrBtnPoint = arrBtnPoint.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        arrBtnSubscript = arrBtnSubscript.sorted(by: { btn1, btn2 in
            return btn1.tag < btn2.tag
        })
        arrBtnSubscript.forEach { btn in
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        arrBtnPoint.forEach { btn in
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
            if product == .subscribe_001 || product == .subscribe_002 || product == .subscribe_003 || product == .subscribe_004 {
                //정기 결제이면
                
                var param = [String:Any]()
                param["user_id"] = ShareData.ins.myId
                param["productId"] = buy_key  //상품코드
                param["point_key"] = "GPA.\(transactionId)" //주문번호 아이폰은 GPA. 붙인다 서버 구분하기 위해
                param["app_type"] = appType //어플종류
                param["purchaseToken"] = receipt
                param["packageName"] = Bundle.main.bundleIdentifier
                param["item_package"] = product.serverItemPackageKey()
                param["ref"] = ""
                
//                param["developerPayload"] = payload //서버에서 생성한 payload sequence
                self?.requestPaymentInAppSubScription(param)
                print("==================\n\n=========== \(JSON(param).stringValue)")
                print("==================\n\n=========== point_key\(transactionId)")
            }
            else {
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
//                self.showErrorToast(res)
                let msg = "\(res)"
                appDelegate.window?.makeToast(msg)
            }
        } fail: { error in
//            self.showErrorToast(error)
            appDelegate.window?.makeToast(NSLocalizedString("point_activity05", comment: "결제오류!!"))
        }
    }
    
    func requestPaymentInAppSubScription(_ param:[String:Any]) {
        ApiManager.ins.requestPaymentInAppSubScription(param: param) { res in
            let code = res["code"].stringValue
            let msg = res["msg"].stringValue
            if code == "000" {
                self.getUserInfo()
                print("결제 성공!!")
                appDelegate.window?.makeToast("\(msg)")
            }
            else {
                appDelegate.window?.makeToast("error: \(msg)\ncode:\(code)")
            }
        } fail: { error in
            if let res = JSON(error) as? JSON {
                let code = res["code"].stringValue
                let msg = res["msg"].stringValue
                appDelegate.window?.makeToast("error: \(msg)\ncode:\(code)")
            }
        }
    }
    func getUserInfo() {
        
        ApiManager.ins.requestUerInfo(param: ["app_type": appType, "user_id": ShareData.ins.myId]) { res in
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
        else if arrBtnSubscript.contains(sender as! CButton) {
            switch sender.tag {
                case 0:
                    print("구독 1")
                    self.requestPayloadId(.subscribe_001)
                    break
                case 1:
                    print("구독 2")
                    self.requestPayloadId(.subscribe_002)
                    break
                case 2:
                    print("구독 3")
                    self.requestPayloadId(.subscribe_003)
                    break
                case 3:
                    print("구독 4")
                    self.requestPayloadId(.subscribe_004)
                    break
                default:
                    break
            }
        }
    }
}

