//
//  PictureAlbumColCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/25.
//

import UIKit

class PictureAlbumColCell: UICollectionViewCell {
    @IBOutlet var ivThumb: UIImageView!
    @IBOutlet var ivPlay: UIImageView!
    @IBOutlet var btnState: CButton!
    @IBOutlet var lbPoint: UILabel!
    @IBOutlet var lb19Pluse: Clabel!
    @IBOutlet var visualEffectView: UIVisualEffectView!
//    @IBOutlet var ivProfile: UIImageView!
//    @IBOutlet var lbNicName: UILabel!
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
    }
    
    func configurationData(model: PictureAlbumModel) {
        
        
        visualEffectView.isHidden = true
        ivPlay.isHidden = true
        
        ivThumb.setImageCache(model.pb_url)
        lb19Pluse.isHidden = (model.bp_adult != "Y")
        
        if model.bp_point > 0  {
            btnState.setTitle(NSLocalizedString("picture_not_charge", comment: "유료"), for: .normal)
            btnState.backgroundColor = .appColor(.appColor)
        }
        else {
            btnState.setTitle(NSLocalizedString("picture_free", comment: "무료"), for: .normal)
            btnState.backgroundColor = .appColor(.blueLight)
        }
        
        if model.bp_point > 0 && model.purchase_status == "N" && model.user_id != ShareData.ins.myId {
            visualEffectView.isHidden = false
        }
     
//        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
//        ivProfile.image = ShareData.ins.mySex.transGender().avatar()
        
//        if let url = Utility.thumbnailUrl(toUserId, user_img),  {
//            cell.ivProfile.setImageCache(url)
//        }
     
//        ivProfile.isHidden = true
//        lbNicName.text = model.user_name
        lbDescription.text = model.bp_subject
        ivPlay.isHidden = (model.bp_type != "V")
        lbPoint.text = "\(model.bp_point)".addComma() + "P"
        
    }
    @objc func onTapGestureHandler(_ gesture: UITapGestureRecognizer) {
        print("clicked")
    }
}
