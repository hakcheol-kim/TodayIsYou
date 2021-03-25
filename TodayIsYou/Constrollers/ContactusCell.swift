//
//  ContactusCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/16.
//

import UIKit
import SwiftyJSON

class ContactusCell: UITableViewCell {
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var svSub: UIStackView!
    
    @IBOutlet weak var ivMangerIcon: UIImageView!
    @IBOutlet weak var lbManagerTitle: UILabel!
    @IBOutlet weak var ivBgView: UIImageView!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var svMsg: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data: JSON?) {
        guard let data = data else {
            lbMessage.text = ""
            lbDate.text = ""
            return
        }
        let answer_date = data["answer_date"].stringValue
        let answer = data["answer"].stringValue
        
        let question = data["question"].stringValue
        let question_date = data["question_date"].stringValue
        
        ivMangerIcon.isHidden = true
        lbManagerTitle.isHidden = true
        let lbTmp = self.getTmpLabel()
        
        ivBgView.backgroundColor = UIColor.clear
        ivBgView.contentMode = .scaleToFill
        
        if answer_date.isEmpty == false {
            svSub.alignment = .leading
            ivMangerIcon.isHidden = false
            lbManagerTitle.isHidden = false
            lbMessage.text = answer
            lbDate.text = answer_date
            svContent.addArrangedSubview(lbTmp)
            
            let img = UIImage(named: "ico_bubble_red")!
            ivBgView.image = img.resizableImage(withCapInsets: UIEdgeInsets(top: 8, left: 8, bottom: 7, right: 7), resizingMode: .stretch)
            lbMessage.textColor = UIColor.white
            svMsg.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 8)
        }
        else {
            svSub.alignment = .trailing
            lbMessage.text = question
            lbDate.text = question_date
            lbMessage.textColor = UIColor.label
            svContent.insertArrangedSubview(lbTmp, at: 0)
            
            let img = UIImage(named: "ico_bubble_gray")!
            ivBgView.image = img.resizableImage(withCapInsets: UIEdgeInsets(top: 8, left: 7, bottom: 7, right: 8), resizingMode: .stretch)
            svMsg.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 12)
        }
        lbMessage.sizeToFit()
        self.layoutIfNeeded()
    }
    func getTmpLabel() -> UILabel {
        if let lbtmp = svContent.viewWithTag(1111) as? UILabel {
            lbtmp.removeFromSuperview()
        }
        let lb = UILabel.init()
        lb.tag = 1111
        lb.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        lb.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        lb.text = ""
        return lb
    }
}
