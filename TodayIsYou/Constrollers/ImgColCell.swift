//
//  ImgColCell.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/07.
//

import UIKit
import UIImageViewAlignedSwift

class ImgColCell: UICollectionViewCell {
    static let identifier = "ImgColCell"
    
    @IBOutlet weak var ivThumb: UIImageViewAligned!
    @IBOutlet weak var btnState: CButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
