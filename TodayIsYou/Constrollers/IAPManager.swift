//
//  IAPManager.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/05/07.
//

import Foundation
import StoreKit

enum Product: String, CaseIterable {
    case point_0
    case point_1
    case point_2
    case point_3
    case point_4
    case point_5
}

struct PointModel {
    let id:Product
    let handler: (() ->Void)
}
extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
}
final class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()
    private var products = [SKProduct]()
    private var productBeingPurchased:SKProduct?
    private var completion: ((_ pram:[String:Any]) -> Void)?
    
    //앱스토어 상품정보를 불러온다.
    public func fetchProductus() {
        let set = Set(Product.allCases.compactMap({ $0.rawValue}))
//        let set = Set(["p_2500","p_5000","p_15000","p_25000","p_50000","p_100000"])
        let request = SKProductsRequest(productIdentifiers: set)
        request.delegate = self
        request.start()
    }
    
    public func purchage(product: Product, completion:@escaping ((_ pram:[String:Any]) -> Void)) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        guard let storeKitProduct = products.first(where: {$0.productIdentifier == product.rawValue}) else {
            return
        }
        AppDelegate.ins.startIndicator()
        self.completion = completion
        let paymentRequset = SKPayment(product: storeKitProduct)
        SKPaymentQueue.default().add(paymentRequset)
        SKPaymentQueue.default().add(self)
    }
    private func validationCheckTransaction(transaction:SKPaymentTransaction) {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//            서버에서 영수증 데이터, 비밀번호 (영수증에 자동 갱신 구독이 포함 된 경우) 및 requestBody에 자세히 설명 된
//            exclude-old-transactions 키를 사용하여 JSON 객체를 생성합니다. 이 JSON 객체를 HTTP POST 요청의 페이로드로 제출합니다.
//            샌드 박스에서 앱을 테스트 할 때와 애플리케이션을 검토하는 동안 테스트 환경
//            URL https://sandbox.itunes.apple.com/verifyReceipt를 사용하십시오. 앱이 App Store에 게시되면 프로덕션
//            URL https://buy.itunes.apple.com/verifyReceipt를 사용하세요. 이러한 엔드 포인트에 대한 자세한 내용은 verifyReceipt를 참조하세요.
            
           
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                
                let receiptString = receiptData.base64EncodedString(options: [])
                guard let orderId = transaction.transactionIdentifier, receiptString.isEmpty == false  else {
                    return
                }
                
                #if DEBUG
                let url: String = "https://sandbox.itunes.apple.com/verifyReceipt"
                #else
                let url: String = "https://buy.itunes.apple.com/verifyReceipt"
                #endif
                
                
                let param = ["transactionId": orderId, "receipt": receiptString]
                self.completion?(param)
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }
    
    ///MARK:: SKProductsRequestDelegate 앱스토어 설정한 상품정보 받음
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        print("fetch item: \(products)")
        products.forEach { p in
            print("fetch item: \(p.priceLocale), \(p.productIdentifier), \(p.localizedPrice())")
        }
    }
    
    // Observe the transaction state
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            AppDelegate.ins.stopIndicator()
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                self.validationCheckTransaction(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            case .failed:
                break
            case .restored:
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        AppDelegate.ins.stopIndicator()
        guard request is SKProductsRequest else {
            return
        }
        print("Product fetch reqeust failed")
    }
}
