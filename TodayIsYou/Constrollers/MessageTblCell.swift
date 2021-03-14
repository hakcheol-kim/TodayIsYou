//
//  MessageTblCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/11.
//

import UIKit
import UIImageViewAlignedSwift
import SwiftyJSON

class MessageTblCell: UITableViewCell {
    @IBOutlet weak var ivProfile: UIImageViewAligned!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var ivThumb: UIImageViewAligned!
    @IBOutlet weak var btnType: CButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configurationData(_ data: JSON) {
        guard let data = data as? JSON else {
            return
        }
        
        
    }
    
}
