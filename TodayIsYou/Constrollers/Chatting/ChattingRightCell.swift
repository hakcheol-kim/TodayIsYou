//
//  ContactusCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/16.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class ChattingRightCell: UITableViewCell {
    static let identifier = "ChattingRightCell"
    
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var svSub: UIStackView!
    @IBOutlet weak var ivBgView: UIImageView!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var ivFile: UIImageView!
    @IBOutlet weak var svMsg: UIStackView!
    
    let calendar = Calendar.init(identifier: .gregorian)
    let df = CDateFormatter()
    var didClickedClosure:((_ selData:Any?, _ actionIdx: Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        df.locale = Locale(identifier: "ko_KR")
        ivFile.layer.cornerRadius = 16
        ivFile.clipsToBounds = true

        ivFile.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGesuterHandler(_ :)))
        ivFile.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data: ChatMessage?, _ profile_name: String? = nil) {
        guard let chat = data else {
            lbMessage.text = ""
            lbDate.text = ""
            return
        }
        var msg = ""
        if let memo = chat.memo, memo.hasPrefix("[CAM_TALK]") {
            msg = memo.replacingOccurrences(of: "[CAM_TALK]", with: "")
        }
        else if let memo = chat.memo, memo.hasPrefix("[PHONE_TALK]") {
            msg = memo.replacingOccurrences(of: "[PHONE_TALK]", with: "")
        }
        else if let memo = chat.memo, memo.hasPrefix("@@##$$|") {
            msg = memo.replacingOccurrences(of: "@@##$$|", with: "")
            msg = "🎁 \(msg)"
        }
        else if let memo = chat.memo {
            msg = memo
        }
        
        lbMessage.text = msg
        if let date = chat.reg_date {
            if calendar.isDateInToday(date) {
                df.dateFormat = "a hh:mm"
            }
            else {
                df.dateFormat = "yy.MM.dd hh:mm"
            }
            lbDate.text = df.string(from: date)
        }
        
        ivBgView.backgroundColor = UIColor.clear
        
        ivBgView.tintColor = .appColor(.gray224)
        guard let img = UIImage(named: "ico_peech_bubble_right") else {
            return
        }
        ivBgView.image = img.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
        lbMessage.textColor = .appColor(.blackText)
        
        ivFile.isHidden = true
        ivBgView.isHidden = false
        
        if let file_name = chat.file_name, file_name.isEmpty == false, let url = Utility.thumbnailUrl(chat.from_user_id, file_name) {
            ivFile.isHidden = false
            ivBgView.isHidden = true
            ivFile.accessibilityValue = url
            
            Utility.downloadImage(url) { (image, _) in
                guard let image = image else {
                    return
                }
                self.ivFile.image = image
                let height = self.ivFile.bounds.width * image.getCropRatio() + self.lbDate.bounds.height + 3 + 16
                print("height : \(height)")
                chat.height = Double(height)
                self.didClickedClosure?(height, 100)
            }
        }
    }
    @objc func tapGesuterHandler(_ gesture:UITapGestureRecognizer) {
        if gesture.view == ivFile {
            self.didClickedClosure?(ivFile.accessibilityValue, 1)
        }
    }
}
