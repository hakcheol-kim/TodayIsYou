//
//  CameraOverlayView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
protocol CameraOverlayViewDelegate {
    func cameraOverlayViewCancelAction()
    func cameraOverlayViewShotAction()
    func cameraOverlayViewRotationAction()
}

@IBDesignable class CameraOverlayView: UIView {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnRotaion: UIButton!
    @IBInspectable @IBOutlet weak var btnShot: CButton!
    var delegate: CameraOverlayViewDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        
        if sender == btnClose {
            delegate?.cameraOverlayViewCancelAction()
        }
        else if sender == btnRotaion {
            delegate?.cameraOverlayViewRotationAction()
            sender.isSelected = !sender.isSelected
        }
        else if sender == btnShot {
            delegate?.cameraOverlayViewShotAction()
        }
    }
}
