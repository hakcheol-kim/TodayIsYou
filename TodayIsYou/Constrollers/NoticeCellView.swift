//
//  NoticeCellView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON
class NoticeCellView: UIView {

    @IBOutlet weak var btnTogle: CButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var tvMemo: CTextView!
    @IBOutlet weak var heightMemo: NSLayoutConstraint!
    
    
    func configurationData(_ data: JSON?) {
        guard let data = data else {
            lbTitle.text = ""
            lbDate.text = ""
            return
        }
        
        let reg_date = data["reg_date"].stringValue    //": "2021-02-26 10:56:51",
//        let use_yn = data["use_yn"].stringValue    //": "Y",
        let memo = data["memo"].stringValue    //": ,
        let t = data["title"].stringValue
        
        lbTitle.text = t
        lbDate.text = reg_date
        do {
            let attr = try NSMutableAttributedString.init(htmlString: memo)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: tvMemo.font?.pointSize ?? 14, weight: .regular), range: NSMakeRange(0, attr.string.length))
            tvMemo.attributedText = attr
        } catch {
            tvMemo.attributedText = nil
        }
        tvMemo.text = memo
        let fitH = tvMemo.sizeThatFits(CGSize(width: self.bounds.size.width - 32, height: CGFloat.greatestFiniteMagnitude)).height
        heightMemo.constant = fitH
        
        tvMemo.isHidden = true
        self.layoutIfNeeded()
    }
    
    @IBAction func onClickedBtnActions(_ sender: CButton) {
        if sender == btnTogle {
            btnTogle.isSelected = !sender.isSelected
            guard let ivArrow = btnTogle.viewWithTag(100) as? UIImageView else {
                return
            }
            
            if btnTogle.isSelected {
                tvMemo.isHidden = false
                ivArrow.image = UIImage(systemName: "chevron.up")
            }
            else {
                tvMemo.isHidden = true
                ivArrow.image = UIImage(systemName: "chevron.down")
            }
        }
    }
}
