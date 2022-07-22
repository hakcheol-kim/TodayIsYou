//
//  AppPermissionViewCtroller.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/05/06.
//

import UIKit
import Foundation
import AppTrackingTransparency
import AppsFlyerLib
import AdSupport

class AppPermissionViewCtroller: UIViewController {
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnMicroPhone: UIButton!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var ivCamera: UIImageView!
    @IBOutlet weak var ivMicroPhone: UIImageView!
    @IBOutlet weak var ivPhoto: UIImageView!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var safetyView: UIView!
    
    var completion:((_ success:Bool) ->Void)?
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PermissionsController.gloableInstance.checkPermissionAppTracking {
            guard let _ = ASIdentifierManager.shared().advertisingIdentifier as? UUID else {
                return
            }
        } failureBlock: {
            
        } deniedBlock: {
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        appDelegate.apptrakingPermissionCheck()
        if let lbSubDes = btnCamera.viewWithTag(102) as? UILabel {
            let des = Bundle.main.localizedString(forKey: "NSCameraUsageDescription", value: nil, table: "InfoPlist")
            lbSubDes.text = des
        }
        
        if let lbSubDes = btnMicroPhone.viewWithTag(102) as? UILabel {
            let des = Bundle.main.localizedString(forKey: "NSMicrophoneUsageDescription", value: nil, table: "InfoPlist")
            lbSubDes.text = des
        }
       
        if let lbSubDes = btnPhoto.viewWithTag(102) as? UILabel {
            let des = Bundle.main.localizedString(forKey: "NSPhotoLibraryUsageDescription", value: nil, table: "InfoPlist")
            lbSubDes.text = des
        }
        
        safetyView.isHidden = !Utility.isEdgePhone()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCamera {
            //camera, camera.fill
            PermissionsController.gloableInstance.checkPermissionAccessForCamera(successBlock: {
                sender.isSelected = true
                self.ivCamera.image = UIImage(systemName: "camera.fill")
            }, failureBlock: {
                print("error: permission")
            }, deniedBlock: {
                self.showSystemSettingAlert(title: NSLocalizedString("permission_camera", comment: "카메라 액세스 할 수 없습니다."), message: NSLocalizedString("permission_camera_setting", comment: "액세스를 사용하려면 설정> 개인 정보 보호> 카메라를 허용해주세요."))
            })
        }
        else if sender == btnMicroPhone {
            //mic, mic.fill
            PermissionsController.gloableInstance.checkPermissionAccessMicrophone {
                sender.isSelected = true
                self.ivMicroPhone.image = UIImage(systemName: "mic.fill")
            } failureBlock: {
                print("fail")
            } deniedBlock: {
                self.showSystemSettingAlert(title: NSLocalizedString("permission_microphone", comment: "마이크를 액세스 할 수 없습니다."), message: NSLocalizedString("permission_microphone_setting", comment: "액세스를 사용하려면 설정> 개인 정보 보호> 마이크를 허용해주세요."))
            }
        }
        else if sender == btnPhoto {
            //mic, mic.fill
            PermissionsController.gloableInstance.checkPermissionAccessGallery {
                sender.isSelected = true
                self.ivPhoto.image = UIImage(systemName: "photo.fill")
            } failureBlock: {
                print("fail")
            } deniedBlock: {
                self.showSystemSettingAlert(title: NSLocalizedString("permission_gallery", comment: "캘러리를 액세스 할 수 없습니다."), message:NSLocalizedString("permission_gallery_stting", comment: "액세스를 사용하려면 설정> 개인 정보 보호> 사진 접근 권한을 허용해주세요."))
            }
        }
        else if sender == btnOk {
            if btnCamera.isSelected == false || btnMicroPhone.isSelected == false {
                self.view.makeToast(NSLocalizedString("permission_check", comment: "권한을 확인해주세요."))
                return
            }
            ShareData.ins.dfsSet(true, DfsKey.checkPermission)
            appDelegate.callIntroViewCtrl()
        }
    }
    
    func showSystemSettingAlert(title:String?, message:String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("activity_txt479", comment: "취소"), style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("activity_txt306", comment: "설정"), style: .default, handler: { action in
            let urlSetting = NSURL.init(string: UIApplication.openSettingsURLString)! as URL
            if UIApplication.shared.canOpenURL(urlSetting) {
                UIApplication.shared.open(urlSetting, options: [:], completionHandler: nil)
            }
            else {
                alert.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
