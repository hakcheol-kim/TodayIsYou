//
//  CamTalkAlertView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/20.
//

import UIKit
import SwiftyJSON
import AlamofireImage

class CamTalkAlertView: UIView {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var starRatingView: FloatRatingView!
    @IBOutlet weak var lbMsg1: UILabel!
    @IBOutlet weak var lbMsg2: UILabel!
    @IBOutlet weak var btnReport: UIButton!
     
    var data:JSON!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data: JSON?) {
        guard let data = data else {
            return
        }
        self.data = data
        let user_score = data["user_score"].doubleValue
        let contents = data["contents"].stringValue
//        let user_sex = data["user_sex"].stringValue
        lbMsg2.text = "*영상,음성 채팅시 차감되는 위 포인트는 상대와의 연결 여부와 상관 없이 차감되며 환불되지 않습니다.영상, 음성 신청시 이에 동의함으로 간주됩니다."
        lbTitle.text  = contents
        starRatingView.rating = user_score
    }
    func getImgUrl() -> String {
        let user_id = data["user_id"].stringValue
        let user_sex = data["user_sex"].stringValue
        
        var imgUrl = "icon_mail"
        if user_sex == Gender.femail.rawValue {
            imgUrl = "icon_female"
        }
        
        let keys:[String] = ["cam_user_img"]// ["file_name", "user_img", "cam_user_img", "talk_user_img"]
        
        for key in keys {
            let value = data[key].stringValue
            if let url = Utility.thumbnailUrl(user_id, value) {
                imgUrl = url
                break
            }
        }
        return imgUrl
    }
    
    func getTitleAttr() -> NSAttributedString {
        let user_name = data["user_name"].stringValue
        let user_age = data["user_age"].stringValue
        let goo_cnt = data["good_cnt"].stringValue

        let tmpStr = "\(user_name), \(user_age), "
        let attr = NSMutableAttributedString.init(string: tmpStr)
        
        guard let img = UIImage(named: "ico_heart")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)  else {
            return NSAttributedString(string: tmpStr)
        }
        let attatch = NSTextAttachment.init(image: img)
        attatch.bounds = CGRect(x: 0, y: -1.5, width: img.size.width, height: img.size.height)
        let tmpAttr = NSAttributedString.init(attachment: attatch)
        attr.append(tmpAttr)
        attr.append(NSAttributedString(string: " \(goo_cnt)"))
        
        return attr
    }
    
}
