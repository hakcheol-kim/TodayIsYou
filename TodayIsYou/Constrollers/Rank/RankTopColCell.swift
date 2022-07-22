//
//  RankTopColCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/11.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class RankTopColCell: UICollectionViewCell {
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var ivBgview: UIImageView!
    @IBOutlet weak var bgView: CView!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var btnImgCnt: UIButton!
    @IBOutlet weak var svPhoto: UIStackView!
    @IBOutlet weak var lbInfo: UILabel!
    @IBOutlet weak var ratingview: FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configurationData(_ data:JSON?) {
        guard let data = data as? JSON else {
            return
        }
        self.addShadow(offset: CGSize(width: 4, height: 4), color: RGBA(0, 0, 0, 0.3), raduius: 4, opacity: 0.3)
        
        let user_sex = data["user_sex"].stringValue  // "여",
        let cam_user_img = data["cam_user_img"].stringValue  // "20210222170907772.jpg",
        let user_r = data["user_r"].intValue  // 240,
        let user_age = data["user_age"].stringValue  // "20대",
        let user_area = data["user_area"].stringValue  // "서울",
        let locale = data["locale"].stringValue  // "",
        let reg_date = data["reg_date"].stringValue  // 1613880538530,
        let good_cnt = data["good_cnt"].intValue  // 17,
        let user_point = data["user_point"].intValue  // 100,
        let sms_auth = data["sms_auth"].stringValue  // "N",
        let user_bbs_point = data["user_bbs_point"].intValue  // 0,
        let user_id = data["user_id"].stringValue  // "7edd7d94de55ca31f6aa9929381bcc1d",
        let talk_user_img = data["talk_user_img"].stringValue  // "",
        let user_img = data["user_img"].stringValue  // null,
        let user_score = data["user_score"].floatValue  // 0,
        let user_name = data["user_name"].stringValue  // "김 보라",
        let orderby_num = data["orderby_num"].intValue  //)" : 3,
        let user_status = data["user_status"].stringValue  // "ON"
        
        lbInfo.text = "\(good_cnt), \(user_name), \(Age.localizedString(user_age))"
        ratingview.rating = Double(user_score)
       
        ivThumb.image = Gender.defaultImg(user_sex)
        
        let keys:[String] = ["user_img", "cam_user_img", "talk_user_img"]
        var urls:[String] = []
        for key in keys {
            let value = data[key].stringValue
            if let imgUrl = Utility.thumbnailUrl(user_id, value) {
                urls.append(imgUrl)
            }
        }
        if let url = urls.first {
            ivThumb.setImageCache(url)
            ivBgview.setImageCache(url)
        }
        
        var i = 0
        for ivImg in svPhoto.arrangedSubviews {
            let ivImg = ivImg as! UIImageViewAligned 
            if i < urls.count {
                ivImg.isHidden = false
                ivImg.setImageCache(urls[i])
            }
            else {
                ivImg.isHidden = true
            }
            i += 1
        }
    }
}
