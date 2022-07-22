//
//  RandomMsgAlertView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/18.
//

import UIKit
import PhotosUI

class RandomMsgAlertView: UIView {
    
    @IBOutlet var arrBtnCheck: [CButton]!
    @IBOutlet weak var tvContent: CTextView!
    var arrTitle = [NSLocalizedString("root_display_txt35", comment: "재미있게 영상 채팅 해요"),
                    NSLocalizedString("root_display_txt48", comment: "고민 들어 주세요"),
                    NSLocalizedString("root_display_txt42", comment: "심심해요")]
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commitUI()
    }
    private func commitUI() {
        let xib = Bundle.main.loadNibNamed("RandomMsgAlertView", owner: self, options: nil)?.first as! UIView
        self.addSubview(xib)
        xib.addConstraintsSuperView()
        self.awakeFromNib()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        arrBtnCheck = arrBtnCheck.sorted(by: { btn1, btn2 in
            return btn1.tag < btn2.tag
        })
        
        for btn in arrBtnCheck {
            btn.localizedKey = arrTitle[btn.tag]
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        tvContent.placeHolderString = NSLocalizedString("random_msg_hint", comment: "")
        tvContent.delegate = self
        tvContent.text = ""
        tvContent.placeholderLabel?.isHidden = true
        self.setNeedsDisplay()
    }
    
    @objc func onClickedBtnActions(_ sender: UIButton) {
        if let sender = sender as? CButton, arrBtnCheck.contains(sender) {
            arrBtnCheck.forEach { btn in
                btn.isSelected = false
            }
            sender.isSelected = true
            tvContent.text = arrTitle[sender.tag]
            self.textViewDidChange(tvContent)
        }
    }
}
extension RandomMsgAlertView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let textView = textView as? CTextView else { return }
        textView.placeholderLabel!.isHidden = !(textView.text.isEmpty)
    }
}
