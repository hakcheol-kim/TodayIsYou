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
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAge: UILabel!
    @IBOutlet weak var lbCnt: UILabel!
    @IBOutlet weak var btnProfile: CButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var starRatingView: FloatRatingView!
    @IBOutlet weak var lbMsg1: UILabel!
    @IBOutlet weak var lbMsg2: UILabel!
    @IBOutlet weak var btnReport: UIButton!
     
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleView.layer.cornerRadius = 16
        self.titleView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        self.btnProfile.imageView?.contentMode = .scaleAspectFill
    }
    
    func configurationData(_ data: JSON?) {
        guard let data = data else {
            lbName.text = ""
            lbAge.text = ""
            lbCnt.text = "0"
            return
        }
        
        let all_user_cnt = data["all_user_cnt"].intValue    //" : 6655,
        let locale = data["locale"].stringValue    //" : "",
        let file_name = data["file_name"].stringValue    //" : "20210225111501918.jpg",
        let seq = data["seq"].intValue    //" : 345,
        let user_image = data["user_image"].stringValue    //" : "20210219145911566.jpg",
        let user_sex = data["user_sex"].stringValue    //" : "여",
        let days = data["days"].intValue    //" : 20,
        let mod_date = data["mod_date"].stringValue    //" : 1614432147507,
        let status = data["status"].stringValue    //" : "N",
        let inapp_cnt = data["inapp_cnt"].intValue    //" : 0,
        let times = data["times"].stringValue    //" : "14:21:40",
        let contents = data["contents"].stringValue    //" : "먼저 영상 신청해 주세요",
        let user_id = data["user_id"].stringValue    //" : "730a0452e3c6ce30dd3bf43382ccd802",
        let first_order = data["first_order"].intValue    //" : 2,
        let user_name = data["user_name"].stringValue    //" : "연지",
        let good_cnt = data["good_cnt"].stringValue    //" : 1,
        let user_age = data["user_age"].stringValue    //" : "20대",
        let user_area = data["user_area"].stringValue    //" : "경기",
        let img_view = data["img_view"].stringValue    //" : "N",
        let view_cnt = data["view_cnt"].intValue    //" : 0
        let user_img = data["user_img"].stringValue
        let user_score = data["user_score"].doubleValue
        
        lbName.text = user_name
        lbAge.text = user_age
        lbCnt.text = "\(good_cnt)".addComma()
        starRatingView.rating = user_score
        
        btnProfile.setImage(Gender.defaultImg(user_sex), for: .normal)
        if let url = Utility.thumbnailUrl(user_id, file_name) {
            btnProfile.setImageCache(url: url, placeholderImgName: nil)
        }
    }
}
