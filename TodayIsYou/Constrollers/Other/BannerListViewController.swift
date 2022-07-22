//
//  BannerListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/06/14.
//

import UIKit
import SwiftyJSON
class BannerListViewController: BaseViewController {

    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var btnNotSee: CButton!
    @IBOutlet weak var btnClose: CButton!
    
    var data = [JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        if let baner = Bundle.main.loadNibNamed("BannerView", owner: self, options: nil)?.first as? BannerView {
            bannerView.addSubview(baner)
            baner.translatesAutoresizingMaskIntoConstraints = false
            baner.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 0).isActive = true
            baner.topAnchor.constraint(equalTo: bannerView.topAnchor, constant:0).isActive = true
            baner.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: 0).isActive = true
            baner.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 0).isActive = true
            baner.configuration(data) { (index, item) in
                print(item)
                let banner_intent = item["banner_intent"].stringValue
                let banner_type = item["banner_type"].stringValue
                if banner_type == "web" {
                    appDelegate.openUrl(banner_intent, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onClickedButtonAction(_ sender: UIButton) {
        if sender == btnNotSee {
            let dateStr = Date().stringDateWithFormat("yyyyMMdd")
            ShareData.ins.dfsSet(dateStr, DfsKey.eventBanerSeeDate)
            self.dismiss(animated: false, completion: nil)
        }
        else if sender == btnClose {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
