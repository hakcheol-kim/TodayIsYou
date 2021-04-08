//
//  MessageTblCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/11.
//

import UIKit
import UIImageViewAlignedSwift
import SwiftyJSON

class MessageTblCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageViewAligned!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var ivThumb: UIImageViewAligned!
    @IBOutlet weak var btnType: CButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configurationData(_ data: JSON?) {
        guard let data = data else {
            lbTitle.text = ""
            lbSubTitle.text = ""
            ivThumb.isHidden = true
            return
        }
        
        let chat_point = data["chat_point"].intValue //0;
        let confirm = data["confirm"].stringValue //Y;
        let days = data["days"].intValue //2;
        let locale = data["locale"].stringValue //"";
        let memo = data["memo"].stringValue //Hi;
        let mode = data["mode"].stringValue //;
        let msg_cnt = data["msg_cnt"].intValue //0;
        let msg_reg_date = data["msg_reg_date"].stringValue//"04:09:45.626 PM 03/11/2021";
        let page = data["page"].intValue //;
        let point_user_id = data["point_user_id"].stringValue //6ccfffe4e4b462557e674b0eb64e0eb7;
        let rownum = data["rownum"].intValue //;
        let seq = data["seq"].intValue //220;
        let talk_img = data["talk_img"].stringValue //"20210311135150182.jpg";
        let times = data["times"].stringValue //21:35:35";
        let user_age = data["user_age"].stringValue //"20\Ub300";
        let user_area = data["user_area"].stringValue //"\Uc11c\Uc6b8";
        let user_bbs_point = data["user_bbs_point"].intValue //0;
        let user_id = data["user_id"].stringValue //6ccfffe4e4b462557e674b0eb64e0eb7;
        let user_img = data["user_img"].stringValue //"20210311135150182.jpg";
        let user_name = data["user_name"].stringValue //"\Uc720\Ubbf8";
        let user_sex = data["user_sex"].stringValue //"\Uc5ec";
        let user_type = data["user_type"].stringValue //1;

        
        if Gender.mail.rawValue == (user_sex as? String) {
            ivProfile.image = UIImage(named: Gender.mail.avatar())
        }
        else {
            ivProfile.image = UIImage(named: Gender.femail.avatar())
        }
        if let imgUrl = Utility.thumbnailUrl(user_id, talk_img) {
            ivProfile.setImageCache(url: imgUrl, placeholderImgName: nil)
        }
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        
//        ivThumb.isHidden = true
//        if let imgUrl = Utility.thumbnailUrl(user_id, user_img) {
//            ivThumb.isHidden = false
//            ivThumb.setImageCache(url: imgUrl, placeholderImgName: nil)
//        }
//        ivThumb.layer.cornerRadius = ivThumb.bounds.height/2
        
        lbTitle.text = memo
        let result = "\(user_name), \(user_age), \(user_sex)"
        let attr = NSMutableAttributedString.init(string: result)
        attr.addAttribute(.foregroundColor, value: RGB(125, 125, 125), range: NSMakeRange(0, result.length))
        attr.addAttribute(.foregroundColor, value: RGB(148, 17, 0), range: NSMakeRange(0, user_name.length))
        attr.addAttribute(.foregroundColor, value: UIColor.label, range: NSMakeRange(result.length-1, 1))
        lbSubTitle.attributedText = attr
        
        let df = CDateFormatter.init()
//        "04:09:45.626 PM 03/11/2021"
        df.dateFormat = "hh:mm:ss.SSS a MM/dd/yyyy"
//        yyyy-MM-dd'T'HH:mm:ss.SSS'Z
        
        lbMsg.text = ""
        
        if let regDate = df.date(from: msg_reg_date) {
            var tStr = ""
            let curDate = Date()
            let comps = curDate - regDate
            
            if let month = comps.month, month > 0 {
                tStr = "\(month)달전"
            }
            else if let day = comps.day, day > 0 {
                tStr = String(format: "%ld일전", day)
            }
            else if let hour = comps.hour, hour > 0 {
                tStr = String(format: "%02ld시간 %02ld분전", hour, (comps.minute ?? 0))
            }
            else if let minute = comps.minute, minute > 0 {
                tStr = String(format: "%02ld분 %02ld초전", minute, (comps.second ?? 0))
            }
            else if let second = comps.second, second > 0 {
                tStr = String(format: "%02ld초전", second)
            }
            lbMsg.text = tStr
        }
    }
    
}
