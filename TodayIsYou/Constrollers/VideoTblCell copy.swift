//
//  VideoTblCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/06.
//

import UIKit

class VideoTblCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var btnType: CButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
    }
}
