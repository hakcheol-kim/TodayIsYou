//
//  CamTblCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/06.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class CamTblCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageViewAligned!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
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
        
        let all_user_cnt = data["all_user_cnt"].intValue //  = 4858;
        let contents = data["contents"].stringValue // = "\Uc5f0\Uc0c1\Uc774 \Uc88b\Uc544\Uc694";
        let days = data["days"].intValue // = 0;
        let file_name = data["file_name"].stringValue //  = "";
        let first_order = data["first_order"].intValue //  = 8;
        let good_cnt = data["good_cnt"].intValue //  = 0;
        let img_view = data["img_view"].stringValue //  = N;
        let inapp_cnt = data["inapp_cnt"].intValue //  = 0;
        let locale = data["locale"].stringValue // = "";
        let mod_date = data["mod_date"].stringValue //  = 1615347384627;
        let seq = data["seq"].stringValue // = 5574;
        let status = data["status"].stringValue // = N;
        let times = data["times"].stringValue // = "00:44:20";
        let user_age = data["user_age"].stringValue //  = "50\Ub300";
        let user_area = data["user_area"].stringValue //  = "\Uc11c\Uc6b8";
        let user_id = data["user_id"].stringValue //  = 314de2f3d751cfb129c93649008cf576;
        let user_image = data["user_image"].stringValue //  = "";
        let user_name = data["user_name"].stringValue //  = "\Ub8e8\Ud321";
        let user_sex = data["user_sex"].stringValue //  = "\Ub0a8";
        let view_cnt = data["view_cnt"].stringValue //  = 0;
        
        if Gender.mail.rawValue == user_sex {
            ivProfile.image = UIImage(named: Gender.mail.avatar())
        }
        else {
            ivProfile.image = UIImage(named: Gender.femail.avatar())
        }
        if let imgUrl = Utility.thumbnailUrl(user_id, file_name) {
            ivProfile.setImageCache(url: imgUrl, placeholderImgName: nil)
        }
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        
        ivThumb.isHidden = true
        if let imgUrl = Utility.thumbnailUrl(user_id, user_image) {
            ivThumb.isHidden = false
            ivThumb.setImageCache(url: imgUrl, placeholderImgName: nil)
        }
        ivThumb.layer.cornerRadius = ivThumb.bounds.height/2
        
        lbTitle.text = contents
        lbSubTitle.text = "\(user_name), \(user_sex) \(user_age)"
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
}
