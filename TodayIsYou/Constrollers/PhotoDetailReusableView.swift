//
//  PhotoDetailReusableView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/30.
//

import UIKit
import UIImageViewAlignedSwift
import SwiftyJSON

class PhotoDetailReusableView: UICollectionReusableView {
    static let identifier = "PhotoDetailReusableView"
    @IBOutlet weak var ivThumb: UIImageViewAligned!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var btnHeartCnt: UIButton!
    @IBOutlet weak var btnHeartCall: CButton!
    @IBOutlet weak var btnMsg: CButton!
    @IBOutlet weak var lbMsg: UILabel!
    
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
//        ivThumb.image = UIImage(named: "img_back4.jpg")
        let user_id = data["user_id"].stringValue
        let file_name = data["file_name"].stringValue
        let user_name = data["user_name"].stringValue
        let user_age = data["user_age"].stringValue
        let user_sex = data["user_sex"].stringValue
        let recommend_cnt = data["recommend_cnt"].numberValue
        
        ivThumb.image = Gender.defaultImg(user_sex)
        if let url = Utility.originImgUrl(user_id, file_name) {
            ivThumb.setImageCache(url: url, placeholderImgName: nil)
        }
        lbName.text = user_name
        btnHeartCnt.setTitle("\(recommend_cnt)", for: .normal)
        lbMsg.text = ""
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        
        if sender == btnHeartCall {
            self.didClickedClosure?(data, 0)
        }
        else if sender == btnMsg {
            self.didClickedClosure?(data, 1)
        }
    }
}
