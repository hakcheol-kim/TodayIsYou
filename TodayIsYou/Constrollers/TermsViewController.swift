//
//  TermsViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
enum TermsType {
    case nomarl
}

class TermsViewController: BaseViewController {
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var tvContent: CTextView!
    var fontContent = UIFont.systemFont(ofSize: 14, weight: .regular)
    var vcTitle: String = "약관"
    var content: String = ""
    var type: TermsType = .nomarl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if vcTitle.isEmpty == false {
            CNavigationBar.drawBackButton(self, vcTitle, #selector(actionNaviBack))
        }
        
        if Utility.isEdgePhone() == false {
            safetyView.isHidden = true
        }
        
        if type == .nomarl {
            btnOk.isHidden = true
            safetyView.isHidden = true
        }
        
        tvContent.insetTop = 8
        tvContent.insetBottom = 8
        tvContent.insetLeft = 8
        tvContent.insetRigth = 8
        
        if content.isEmpty == false {
            do {
                let attr = try NSMutableAttributedString(htmlString: content)
                attr.addAttribute(.font, value: fontContent, range: NSMakeRange(0, attr.string.length))
                tvContent.attributedText = attr
            } catch {
                tvContent.attributedText = nil
            }
        }
    }
}
