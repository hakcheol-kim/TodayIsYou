//
//  PointHistoryViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/15.
//

import UIKit
enum PointHistoryType {
    case point, star, exchange
    
    func displayName() ->String {
        if self == .point {
            return "포인트 적립 소모내역"
        }
        else if self == .star {
            return "별 적립 소모 내역"
        }
        else if self == .exchange {
            return "별 환급 목록"
        }
        else {
           return ""
        }
    }
}
class PointHistoryViewController: BaseViewController {
    var type: PointHistoryType = .point
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, type.displayName(), #selector(actionNaviBack))
    }
}
