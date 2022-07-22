//
//  ListTypeButton.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/18.
//

import UIKit

class ListTypeButton: UIButton {
    @IBOutlet weak var selectionBg: UIView!
    @IBOutlet weak var ivLeft: UIImageView!
    @IBOutlet weak var ivRight: UIImageView!
    
    var listType: ListType!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commitInit()
    }
    
    private func commitInit() {
        let xib = Bundle.main.loadNibNamed("ListTypeButton", owner: self, options: nil)?.first as! UIView
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
        
        self.setTitle("", for: .normal)
        self.clipsToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            let selWidth = self.bounds.width*0.5
            if self.isSelected {
                self.ivLeft.tintColor = .appColor(.gray125)
                self.ivRight.tintColor = .appColor(.whiteText)
            
                selectionBg.frame = CGRect(x: self.bounds.width - selWidth, y: 0, width: selWidth, height: self.bounds.height)
                self.selectionBg.addShadow(offset: CGSize(width: -2, height: 2), color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3), raduius: 2, opacity: 0.3)
            }
            else {
                self.ivLeft.tintColor = .appColor(.whiteText)
                self.ivRight.tintColor = .appColor(.gray125)
                selectionBg.frame = CGRect(x: 0, y: 0, width: selWidth, height: self.bounds.height)
                self.selectionBg.addShadow(offset: CGSize(width: 2, height: 2), color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3), raduius: 2, opacity: 0.3)
                
            }
            self.selectionBg.layer.cornerRadius = self.bounds.height/2;
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear) {
                self.layoutIfNeeded()
            } completion: { finish in
            }
        }
    }
}
