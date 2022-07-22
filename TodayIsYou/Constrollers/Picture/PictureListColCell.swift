//
//  PictureListColCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/25.
//

import UIKit

class PictureListColCell: UICollectionViewCell {
    @IBOutlet var ivThumb: UIImageView!
    @IBOutlet var ivPlay: UIImageView!
    @IBOutlet var btnState: CButton!
    @IBOutlet var lbPoint: UILabel!
    @IBOutlet var lb19Pluse: Clabel!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var ivProfile: UIImageView!
    @IBOutlet var lbNicName: UILabel!
    @IBOutlet var lbDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let effect = UIBlurEffect.init(style: .extraLight)
        visualEffectView.effect = effect
        visualEffectView.alpha = 0.85
        
        ivPlay.layer.cornerRadius = ivPlay.bounds.height/2
        ivPlay.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapGestureHandler(_ :))))
        ivPlay.contentMode = .scaleToFill
        
        self.contentView.layer.cornerRadius = 4
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.appColor(.gray225).cgColor
        self.contentView.clipsToBounds = true
        
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        ivProfile.layer.borderColor = UIColor.appColor(.gray221).cgColor
        ivProfile.layer.borderWidth = 0.5
        ivProfile.contentMode = .scaleAspectFill
    }
    
    func configurationData(model: PictureModel) {
        
        visualEffectView.isHidden = true
        ivPlay.isHidden = true
        
        let isMe = (ShareData.ins.myId == model.user_id)
        
        ivThumb.setImageCache(model.pb_url)
        lb19Pluse.isHidden = (model.bp_adult != "Y")
        
        if model.ol_cnt == 0 && model.bp_point > 0 && isMe == false {
            visualEffectView.isHidden = false
        }
        
        if model.bp_point > 0 {
            btnState.setTitle(NSLocalizedString("picture_not_charge", comment: "유료"), for: .normal)
            btnState.backgroundColor = .appColor(.appColor)
        }
        else {
            btnState.setTitle(NSLocalizedString("picture_free", comment: "무료"), for: .normal)
            btnState.backgroundColor = .appColor(.blueLight)
        }
        
        if model.user_img.length > 0 {
            ivProfile.setImageCache(model.user_img, nil)
        }
        
        lbNicName.text = model.user_name + ", " + model.user_age + "[\(model.seq)]"
        lbDescription.text = model.bp_subject
        ivPlay.isHidden = (model.bp_type != "V")
        
        lbPoint.text = "\(model.bp_point)".addComma() + "P"
        
        
        
    }
    @objc func onTapGestureHandler(_ gesture: UITapGestureRecognizer) {
        print("clicked")
    }
}
