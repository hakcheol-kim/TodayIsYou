//
//  PhotoView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/16.
//

import UIKit
import UIImageViewAlignedSwift

class PhotoView: UIView {
    @IBOutlet weak var ivPhoto: UIImageViewAligned!
    @IBOutlet weak var btnClose: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commitUI()
    }
    func commitUI() {
        guard let xib = Bundle.main.loadNibNamed("PhotoView", owner: self, options: nil)?.first as? UIView else { return }
        self.addSubview(xib)
        xib.addConstraintsSuperView()
        self.awakeFromNib()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        if self == btnClose {
            self.removeFromSuperview()
        }
    }
}
