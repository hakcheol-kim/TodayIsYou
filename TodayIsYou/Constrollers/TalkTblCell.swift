//
//  CamTblCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/06.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class TalkTblCell: UITableViewCell {
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
            lbMsg.text = ""
            ivThumb.isHidden = true
            return
        }
        
//        let view_cnt = data["view_cnt"].intValue //: 0,
//        let user_bbs_point = data["user_bbs_point"].intValue //: 0,
        let user_name = data["user_name"].stringValue //: "포커땜에",
        let user_age = data["user_age"].stringValue //: "10대",
//        let dong = data["dong"].stringValue //: null,
        let title = data["title"].stringValue //: "동갑 친구가 좋아요",
//        let locale = data["locale"].stringValue //: "",
        let user_img = data["user_img"].stringValue //: "",
//        let gu = data["gu"].stringValue //: null,
        let user_sex = data["user_sex"].stringValue //: "여",
        let talk_img = data["talk_img"].stringValue //: "",
        let reg_date = data["reg_date"].stringValue //: "2021-03-11 07:35:32",
//        let times = data["times"].stringValue //: "01:49:12",
        let user_id = data["user_id"].stringValue //: "6d4bc245c19f038ab6b70d44aef72f99",
        let user_area = data["user_area"].stringValue //: "서울",
//        let si = data["si"].stringValue //: null,
//        let days = data["days"].intValue //: 0,
//        let seq = data["seq"].intValue //: 5931

        if Gender.mail.rawValue == user_sex {
            ivProfile.image = UIImage(named: Gender.mail.avatar())
        }
        else {
            ivProfile.image = UIImage(named: Gender.femail.avatar())
        }
        if let imgUrl = Utility.thumbnailUrl(user_id, talk_img) {
            ivProfile.setImageCache(imgUrl)
        }
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        
        ivThumb.isHidden = true
        if let imgUrl = Utility.thumbnailUrl(user_id, user_img) {
            ivThumb.isHidden = false
            ivThumb.setImageCache(imgUrl)
        }
        ivThumb.layer.cornerRadius = ivThumb.bounds.height/2
        
        lbTitle.text = title
        let result = "\(user_name), \(user_age), \(user_sex)"
        let attr = NSMutableAttributedString.init(string: result)
        attr.addAttribute(.foregroundColor, value: UIColor.label, range: NSMakeRange(0, result.length))
        attr.addAttribute(.foregroundColor, value: RGB(148, 17, 0), range: NSMakeRange(0, user_name.length))
        lbSubTitle.attributedText = attr
        
        let df = CDateFormatter.init()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss" // "2021-03-11 07:35:32
        var tStr = ""
        
        if let regDate = df.date(from: reg_date) {
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
        }
        lbMsg.text = "\(user_area), \(tStr)"
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
}
