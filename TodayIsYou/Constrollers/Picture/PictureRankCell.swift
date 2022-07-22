//
//  PictureRankCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/27.
//

import UIKit

class PictureRankCell: UITableViewCell {
    @IBOutlet weak var profileBgView: CView!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbRankCnt: Clabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbArea: UILabel!
    @IBOutlet weak var btnPicture: CButton!
    @IBOutlet weak var lbCnt: Clabel!
    @IBOutlet weak var btnMsg: CButton!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var markBgView: UIView!
    var model: PictureRank!
    var didAction: ((_ action: Int, _ model:PictureRank) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configurationData(_ model: PictureRank, rank: Int) {
        self.model = model
        lbContent.text = model.contents
        lbRankCnt.text = "\(rank)"
        
        if model.user_img.length > 0 {
            ivProfile.setImageCache(model.user_img)
        }
        
        let reuslt = model.user_name+","+"\(model.user_age)"
        
        let attr = NSMutableAttributedString.init(string: reuslt)
        attr.addAttribute(.foregroundColor, value: UIColor.appColor(.darkRedText), range: (reuslt as NSString).range(of: model.user_name))
        
        lbMsg.attributedText = attr
        lbCnt.isHidden = true
        if model.cnt > 0 {
            lbCnt.isHidden = false
            lbCnt.text = "\(model.cnt)"
        }
        lbArea.isHidden = true
        
        let scale = CGAffineTransform(scaleX: 4, y: 4)
        let rotation = CGAffineTransform(rotationAngle: (45.0 * .pi)/180)
        let move = CGAffineTransform(translationX: -6, y: -6)
        let combine = scale.concatenating(rotation).concatenating(move)
        markBgView.transform = combine
        if rank  > 3 {
            markBgView.backgroundColor = .appColor(.gray170)
        }
        else {
            markBgView.backgroundColor = .appColor(.appColor)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnPicture {
            self.didAction?(100, model)
        }
        else if sender == btnMsg {
            self.didAction?(200, model)
        }
    }
}
