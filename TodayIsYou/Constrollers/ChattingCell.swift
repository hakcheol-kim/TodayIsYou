//
//  ContactusCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/16.
//

import UIKit
import SwiftyJSON

class ChattingCell: UITableViewCell {
    static let identifier = "ChattingCell"
    
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

            ivBgView.tintColor = UIColor(named: "chat_bubble_color_sent")
            guard let img = UIImage(named: "ico_peech_bubble_left") else {
                return
            }
            ivBgView.image = img.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            lbMessage.textColor = UIColor(named: "chat_text_color_sent")
            
            svMsg.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 8)
        }
        else {
            svSub.alignment = .trailing
            lbMessage.text = question
            lbDate.text = question_date
            lbMessage.textColor = UIColor.label
            svContent.insertArrangedSubview(lbTmp, at: 0)
            
            ivBgView.tintColor = UIColor(named: "chat_bubble_color_received")
            guard let img = UIImage(named: "ico_peech_bubble_right") else {
                return
            }
            ivBgView.image = img.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            lbMessage.textColor = UIColor(named: "chat_text_color_received")
            
            svMsg.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 16)
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
