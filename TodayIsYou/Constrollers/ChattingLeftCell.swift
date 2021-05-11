//
//  ContactusCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/16.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift

class ChattingLeftCell: UITableViewCell {
    
    static let identifier = "ChattingLeftCell"
    
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var svSub: UIStackView!
    @IBOutlet weak var ivFile: UIImageView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivBgView: UIImageView!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var svMsg: UIStackView!
    
    let calendar = Calendar.init(identifier: .gregorian)
    let df = CDateFormatter()
    var chat:ChatMessage!
    var didClickedClosure:((_ selData:Any?, _ actionIdx: Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        df.locale = Locale(identifier: "ko_KR")
        ivFile.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGesuterHandler(_ :)))
        ivFile.addGestureRecognizer(tap)
        
        ivFile.layer.cornerRadius = 16
        ivFile.clipsToBounds = true
        
        let tap2 = UITapGestureRecognizer.init(target: self, action: #selector(tapGesuterHandler(_ :)))
        ivBgView.addGestureRecognizer(tap2)
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
        self.chat = chat
        ivIcon.layer.cornerRadius = 18
        
        ivBgView.backgroundColor = UIColor.clear
        ivBgView.contentMode = .scaleToFill
        svSub.alignment = .leading
        lbName.text = chat.to_user_name
        
        lbMessage.attributedText = nil
        
        ivBgView.accessibilityValue = nil
        if let memo = chat.memo {
            var attr:NSMutableAttributedString!
            if memo.hasPrefix("[CAM_TALK]") == true {
                let msg = memo.replacingOccurrences(of: "[CAM_TALK]", with: "")
                attr = NSMutableAttributedString.init(string: msg)
                ivBgView.accessibilityValue = "CAM_TALK"
                if let img = UIImage(named: "cam_icon")?.withRenderingMode(.alwaysTemplate) {
                    let attatch = NSTextAttachment.init(image: img)
                    attatch.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
                    attr.append(NSAttributedString.init(string: " "))
                    attr.append(NSAttributedString.init(attachment: attatch))
                }
            }
            else if memo.hasPrefix("[PHONE_TALK]") == true {
                let msg = memo.replacingOccurrences(of: "[PHONE_TALK]", with: "")
                attr = NSMutableAttributedString.init(string: msg)
                ivBgView.accessibilityValue = "PHONE_TALK"
                if let img = UIImage(named: "phone")?.withRenderingMode(.alwaysTemplate) {
                    let attatch = NSTextAttachment.init(image: img)
                    attatch.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
                    attr.append(NSAttributedString.init(string: " "))
                    attr.append(NSAttributedString.init(attachment: attatch))
                }
            }
            else {
                attr = NSMutableAttributedString.init(string: memo)
            }
            
            lbMessage.attributedText = attr
        }
        
        
        if let date = chat.reg_date {
            if calendar.isDateInToday(date) {
                df.dateFormat = "a hh:mm"
            }
            else {
                df.dateFormat = "yy.MM.dd hh:mm"
            }
            lbDate.text = df.string(from: date)
        }
        ivIcon.image = UIImage(systemName: "person.fill")
        if let url = Utility.thumbnailUrl(chat.from_user_id, profile_name) {
            ivIcon.setImageCache(url)
        }
        ivBgView.backgroundColor = UIColor.clear
        ivBgView.tintColor = UIColor(named: "chat_bubble_color_sent")
        guard let img = UIImage(named: "ico_peech_bubble_left") else {
            return
        }
        ivBgView.image = img.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
        lbMessage.textColor = UIColor(named: "chat_text_color_sent")
    
        ivFile.isHidden = true
        ivBgView.isHidden = false
        
        if let file_name = chat.file_name, file_name.isEmpty == false {
            var thumbnailUrl = ""
            if file_name.hasPrefix("http:") || file_name.hasPrefix("https:") {
                thumbnailUrl = file_name
            }
            else if let url = Utility.thumbnailUrl(chat.from_user_id, file_name) {
                thumbnailUrl = url
            }
           
            ivFile.isHidden = false
            ivBgView.isHidden = true
            ivFile.accessibilityValue = thumbnailUrl
            
            Utility.downloadImage(thumbnailUrl) { (image, _) in
                guard let image = image else {
                    return
                }
                self.ivFile.image = image
                let height = self.ivFile.bounds.width * image.getCropRatio() + self.lbName.bounds.height + self.lbDate.bounds.height + 6 + 16
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
        else if gesture.view == ivBgView {
            guard let value = gesture.view?.accessibilityValue, value.isEmpty == false else {
                return
            }
            
            if value == "CAM_TALK" {
                self.didClickedClosure?(value, 101)
            }
            else if value == "PHONE_TALK" {
                self.didClickedClosure?(value, 102)
            }
        }
    }
    
}
