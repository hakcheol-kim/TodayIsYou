//
//  PictureAddPhotoView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/16.
//

import UIKit

class PictureAddPhotoView: UIView {
    
    @IBOutlet weak var btnAddPhoto: UIButton!
    @IBOutlet weak var svContent: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commitUI()
    }
    func commitUI() {
        guard let xib = Bundle.main.loadNibNamed("PictureAddPhotoView", owner: self, options: nil)?.first as? UIView else { return }
        self.addSubview(xib)
        xib.addConstraintsSuperView()
        self.awakeFromNib()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        if sender == btnAddPhoto {
            self.removeFromSuperview()
        }
    }
}
