//
//  CameraViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
import AVKit
import Mantis
import Photos

public let maxResizeImge:CGFloat = 600
typealias DidFinishCImagePicker = ((_ orgImg: UIImage?, _ cropImg:UIImage?) ->Void)

class CImagePickerController: UIImagePickerController {
    var overlayView: CameraOverlayView? = nil
    var originImg: UIImage?
    var isCrop:Bool = true
    var didFinish:DidFinishCImagePicker?
    
    convenience init(_ sourceType: UIImagePickerController.SourceType, _ didFinish:DidFinishCImagePicker?) {
        self.init()
        self.sourceType = sourceType
        self.didFinish = didFinish
        
        if sourceType == .camera {
            self.modalPresentationStyle = .fullScreen
            self.modalTransitionStyle = .crossDissolve
            self.delegate = self
            self.sourceType = UIImagePickerController.SourceType.camera
            self.navigationController?.navigationBar.isHidden = true
            self.toolbar.isHidden = true
            self.allowsEditing = false
            self.showsCameraControls = false
         
            let scrrenRect = UIScreen.main.bounds
            overlayView = Bundle.main.loadNibNamed("CameraOverlayView", owner: nil, options: nil)?.first as? CameraOverlayView
            
            overlayView?.frame = scrrenRect
            overlayView?.delegate = self
            self.cameraOverlayView = overlayView
            
            let ratio: Float = 4.0/3.0
            let imageHeight : Float = floorf(Float(scrrenRect.width)*ratio)
            let scale: Float = Float(scrrenRect.height)/imageHeight
            let trans: Float = (Float(scrrenRect.height) - imageHeight) / 2
            let translate = CGAffineTransform(translationX: 0.0, y: CGFloat(trans))
            let final = translate.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
            
            self.cameraViewTransform = final
        }
        else {
            self.allowsEditing = false
            self.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.checkPermissionAfterShowImagePicker()
    }
    
    func checkPermissionAfterShowImagePicker() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == AVAuthorizationStatus.denied {
            let alert = UIAlertController.init(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "취소", style: .cancel, handler: { (action) in
                alert.dismiss(animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction.init(title: "설정", style: .default, handler: { (action) in
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                } else {
                    alert.dismiss(animated: false, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if authStatus == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [self] granted in
                if granted {
//                    DispatchQueue.main.async(execute: { [self] in
//                        displayImagePicker()
//                    })
                }
            })
        }
//        else {
//            displayImagePicker()
//        }
    }
}
extension CImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let orgImg = info[UIImagePickerController.InfoKey.originalImage]
        
        if let orgImg = orgImg {
            self.originImg = (orgImg as! UIImage)
            
            if (self.isCrop) {
                let vc = Mantis.cropViewController(image: orgImg as! UIImage)
                vc.delegate = self
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false)
            }
            else {
                self.didFinish?(self.originImg, nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension CImagePickerController: CameraOverlayViewDelegate {
    func cameraOverlayViewCancelAction() {
        self.dismiss(animated: false)
    }
    func cameraOverlayViewShotAction() {
        self.takePicture()
    }
    func cameraOverlayViewRotationAction() {
        if self.cameraDevice == UIImagePickerController.CameraDevice.rear {
            self.cameraDevice = .front
        }
        else {
            self.cameraDevice = .rear
        }
    }
}

extension CImagePickerController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: false)
        let resizeImg = cropped.resized(toWidth: maxResizeImge)
        self.didFinish?(self.originImg, resizeImg)
        self.dismiss(animated: false, completion: nil)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: false) {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
