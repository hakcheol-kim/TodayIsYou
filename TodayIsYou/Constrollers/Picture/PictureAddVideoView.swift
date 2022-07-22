//
//  PictureAddVideoView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/16.
//

import UIKit

class PictureAddVideoView: UIView {
    
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var btnThumb: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commitUI()
    }
    func commitUI() {
        guard let xib = Bundle.main.loadNibNamed("PictureAddVideoView", owner: self, options: nil)?.first as? UIView else { return }
        self.addSubview(xib)
        xib.addConstraintsSuperView()
        self.awakeFromNib()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        if sender == btnVideo {
            self.removeFromSuperview()
        }
    }
}
