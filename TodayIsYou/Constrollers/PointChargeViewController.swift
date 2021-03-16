//
//  PointChargeViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit

class PointChargeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, "포인트 충전", #selector(actionNaviBack))
    }
    
}
