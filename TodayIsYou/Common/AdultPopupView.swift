//
//  AdultPopupView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/23.
//

import UIKit
import Alamofire
import Imaginary

class AdultPopupView: UIView {
    @IBOutlet weak var btnExit: CButton!
    @IBOutlet weak var btnRegist: CButton!
    
    @IBOutlet weak var btnExit2: CButton!
    @IBOutlet weak var btnOk: CButton!
    
    var type: Int = 1
    private var xib: UIView!
    convenience init(type: Int) {
        self.init()
        self.type = type
        self.commitXib()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commitXib()
    }
    private func commitXib() {
        
        guard let xibs = Bundle.main.loadNibNamed("AdultPopupView", owner: self, options: nil) else {
            return
        }
        
        if type == 1 {
            self.xib = (xibs.first as! UIView)
        }
        else {
            self.xib = (xibs.last as! UIView)
        }
        self.addSubview(xib)
        xib.addConstraintsSuperView()
        
        self.layer.cornerRadius = 16
        self.layer.borderColor = UIColor.appColor(.appColor).cgColor
        self.layer.borderWidth = 2
        
        self.awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
}
