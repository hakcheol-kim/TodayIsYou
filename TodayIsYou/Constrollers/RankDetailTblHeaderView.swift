//
//  PhotoDetailReusableView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/30.
//

import UIKit
import UIImageViewAlignedSwift
import SwiftyJSON

class RankDetailTblHeaderView: UIView {
    static let identifier = "RankDetailTblHeaderView"
    @IBOutlet weak var ivThumb: UIImageViewAligned!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAge: UILabel!
    @IBOutlet weak var btnReport: CButton!
    @IBOutlet weak var btnMsg: CButton!
    @IBOutlet weak var btnCamCall: CButton!
    @IBOutlet weak var starRatingView: FloatRatingView!
    
    var animator: UIViewPropertyAnimator!
    let visuableEffectView = UIVisualEffectView(effect: nil)
    var didClickedClosure:((_ selData:JSON?, _ actionIdx: Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupVisualEffectBlur()
    }
    var data:JSON!
    
    fileprivate func setupVisualEffectBlur() {
        self.addSubview(self.visuableEffectView)
        visuableEffectView.isUserInteractionEnabled = false
        self.visuableEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.visuableEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.visuableEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.visuableEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.visuableEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.animator = UIViewPropertyAnimator(duration: 3, curve: .linear)
        self.animator.addAnimations {
            let blurEffect = UIBlurEffect(style: .regular)
            self.visuableEffectView.effect = blurEffect
        }
    }
    
    func configurationData(_ data: JSON) {
        self.data = data

        let user_id = data["user_id"].stringValue
        let user_name = data["user_name"].stringValue
        let user_age = data["user_age"].stringValue
        let user_sex = data["user_sex"].stringValue
        let user_score = data["user_score"].doubleValue
        
        ivThumb.image = Gender.defaultImg(user_sex)
        let keys:[String] = ["user_img", "cam_user_img", "talk_user_img"]
        var urls:[String] = []
        for key in keys {
            let value = data[key].stringValue
            if let imgUrl = Utility.originImgUrl(user_id, value) {
                urls.append(imgUrl)
            }
        }
        if let url = urls.first {
            ivThumb.setImageCache(url: url, placeholderImgName: nil)
        }
        
        lbName.text = user_name
        lbAge.text = user_age
        starRatingView.rating = user_score
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        
        if sender == btnReport {
            self.didClickedClosure?(data, 0)
        }
        else if sender == btnMsg {
            self.didClickedClosure?(data, 1)
        }
        if sender == btnCamCall {
            self.didClickedClosure?(data, 2)
        }
    }
}
