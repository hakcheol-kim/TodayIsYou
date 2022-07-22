//
//  PointPurchaseViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import StoreKit
import SwiftyJSON
import AppsFlyerLib

class PointPurchaseViewController: BaseViewController {
    @IBOutlet weak var lbPointTitle: Clabel!
    @IBOutlet var arrBtnPoint: [CButton]!
    @IBOutlet weak var btnContactus: CButton!
    @IBOutlet weak var lbCurPoint: UILabel!
    @IBOutlet var arrBtnSubscript: [CButton]!
    @IBOutlet weak var btnTerm: UIButton!
    
    var points = [PointModel]()
    var prod = Product(rawValue: "null")
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
        
        let attr = NSAttributedString.init(string: NSLocalizedString("join_activity42", comment: ""), attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue])
        btnTerm.setAttributedTitle(attr, for: .normal)
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
        // 푸쉬 데이터가 있으면 결제 팝업이 뜨고 닫힐때 appdelegate didbecomactive 로직 타면서
        // 화면 빠져 나가 충전이 안되는 케이스가 발생해 결제는 되고 충전 완료 api 때리지 못해 충전이 안되는 케이스 발생
        // 앱 시작할때 didfinish push data 제거 추가했는대 방어적으로 또 추가함
        ShareData.ins.dfsRemove(DfsKey.pushData)
         
        appDelegate.startIndicator()
        IAPManager.shared.purchage(product: product) {[weak self] result in
            appDelegate.stopIndicator()
            guard let self = self else { return }
            guard let transactionId = result["transactionId"],  let receipt = result["receipt"] else {
                print("error: transactionIdentifiy, receipt empty")
                return
            }
            self.prod = product
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
                self.requestPaymentInAppSubScription(param)
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
                self.requestSaveInAppPoint(param)
            }
            
        }
    }
    
    func logoPurchaseEvent(_ param: [String : Any]) {
        let transactionId = param["point_key"]!
        guard let price = prod?.productPrice(), let numPrice = Int(price), let productId = prod?.severProductId() else { return }
        AppsFlyerEvent.addEventLog(.inapp, [
            AFEventParamOrderId: transactionId,
            AFEventParamContentType : "ios_inapp",
            AFEventParamContent: productId,
            AFEventParamRevenue: numPrice,
            AFEventParamCurrency: "KRW",
            AFEventParamReceiptId: (param["purchaseToken"] ?? ""),
            AFEventParam1: ShareData.ins.myId,
            AFEventParam2: (param["app_type"] ?? ""),
            AFEventParam3: (param["packageName"] ?? "")
        ])
    }
    
    func cps(){
        
        var dbdb = [String:Any]()
        dbdb["dbdbdeep_pcode"] = prod;
        dbdb["dbdbdeep_name"] = ShareData.ins.myName ;
        // mjkim 2021.07.28
        dbdb["dbdbdeep_price"] = prod?.productPrice();
        dbdb["dbdbdeep_ptype"] = "애플인앱";
        dbdb["dbdbdeep_ms"] = "today";
        dbdb["mb"] = "Y";
        
        self.requestdbdbDeep(dbdb)
    }
    
    func requestdbdbDeep(_ param:[String:Any]){
        ApiManager.ins.requestdbdbdeep(param: param) { res in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                print("cps성공!!")
            }
            else {
                print("cps오류!!")
            }
        } fail: { error in
            print("cps에러!!")
        }
    }
    
    func requestSaveInAppPoint(_ param:[String:Any]) {
        ApiManager.ins.requestSaveAppPoint(param: param) { res in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.getUserInfo()
                self.cps()
                self.logoPurchaseEvent(param)
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
        let param = ["app_type": appType, "user_id": ShareData.ins.myId]
        ApiManager.ins.requestUerInfo(param: param) { res in
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
        else if let sender = sender as? CButton, arrBtnPoint.contains(sender) {
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
        else if let sender = sender as? CButton, arrBtnSubscript.contains(sender) {
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
        else if sender == btnTerm {
            ApiManager.ins.requestSubscriptionTerm { res in
                var terms = res["terms"].stringValue
                if terms.isEmpty == false {
                    let vc = TermsViewController.init()
                    terms = terms.replacingOccurrences(of: "<br />", with: "")
                    vc.vcTitle = NSLocalizedString("join_activity42", comment: "")
                    vc.content = terms
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    
                }
            } failure: { error in
                self.showErrorToast(error)
            }
        }
    }
}

