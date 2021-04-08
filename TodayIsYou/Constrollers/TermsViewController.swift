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
        
        if content.isEmpty == false {
            let paragraph = NSMutableParagraphStyle.init()
            paragraph.headIndent = 10
            paragraph.paragraphSpacing = 5;
            
            let attr = NSMutableAttributedString.init(string: content)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, content.length))
            attr.addAttribute(.paragraphStyle, value: paragraph, range: NSMakeRange(0, content.length))
            
            tvContent.attributedText = attr
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
