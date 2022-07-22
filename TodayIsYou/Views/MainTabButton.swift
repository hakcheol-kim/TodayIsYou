//
//  MainTabButton.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/18.
//

import UIKit

class MainTabButton: UIButton {
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var unlineView: UIView!
    @IBOutlet weak var btnCnt: UIButton!
    var tabId: MainTab!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commitInit()
    }
    
    private func commitInit() {
        let xib = Bundle.main.loadNibNamed("MainTabButton", owner: self, options: nil)?.first as! UIView
        xib.frame = self.bounds
        self.addSubview(xib)
        xib.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        xib.translatesAutoresizingMaskIntoConstraints = false
        xib.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        xib.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        xib.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        xib.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        self.awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbTitle.text = ""
        ivIcon.image = nil
//        if let font = btnCnt.titleLabel?.font {
//            btnCnt.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
//        }
        btnCnt.isHidden = true
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                lbTitle.textColor = .appColor(.redText)
                unlineView.backgroundColor = .appColor(.redText)
                if let tabId = tabId {
                    ivIcon.image = tabId.selectedImage
                }
            }
            else {
                lbTitle.textColor = .appColor(.blackText)
                unlineView.backgroundColor = UIColor.clear
                if let tabId = tabId {
                    ivIcon.image = tabId.normalImage
                }
            }
        }
    }
}
