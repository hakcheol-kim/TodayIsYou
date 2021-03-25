//
//  PointChargeViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit

class PointChargeViewController: BaseViewController {
    @IBOutlet var arrBtnPoint: [CButton]!
    @IBOutlet weak var btnContactus: CButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrBtnPoint = arrBtnPoint.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        
        for btn in arrBtnPoint {
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        
        CNavigationBar.drawBackButton(self, "포인트 충전", #selector(actionNaviBack))
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnContactus {
            
        }
    }
}
