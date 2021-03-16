//
//  TermsViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit

class TermsViewController: BaseViewController {
    let vcTitle: String = "약관"
    let content: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, nil, nil)
    }
}
