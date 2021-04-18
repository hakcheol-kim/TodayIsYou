//
//  PermissionsController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/21.
//

import UIKit
import Contacts
import AVFoundation
import EventKit
import AVFoundation
import AssetsLibrary
import CoreBluetooth
import CoreNFC

typealias PermissionVoidBlock = () -> Void
class PermissionsController: NSObject {
    static let gloableInstance = PermissionsController()
    
    var copySuccesBlock: PermissionVoidBlock?
    var copyFailureBlock: PermissionVoidBlock?
    var copyDeniedBlock: PermissionVoidBlock?
    
    func checkPermissionAccessForContacts(successBlock: PermissionVoidBlock?, failureBlock: PermissionVoidBlock?, deniedBlock: PermissionVoidBlock?) {
        
        let authState = CNContactStore.authorizationStatus(for: .contacts)
        if authState == .notDetermined {
            CNContactStore().requestAccess(for: .contacts, completionHandler: { granted, error in
                DispatchQueue.main.async {
                    if (granted) {
                        successBlock?()
                    }
                    else {
                        failureBlock?();
                    }
                }
            })
        }
        else if authState == .authorized {
            successBlock?();
        }
        else if authState == .denied {
            deniedBlock?()
        }
        else {
            failureBlock?()
        }
    }
    
    func checkPermissionAccessForCameraAndGallery(_ successBlock: PermissionVoidBlock?, _ failureBlock: PermissionVoidBlock?, _ deniedBlock: PermissionVoidBlock?) {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .authorized {
            successBlock?()
        }
        else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        successBlock?()
                    }
                    else {
                        failureBlock?()
                    }
                }
            }
        }
        else if authStatus == .denied {
            deniedBlock?()
        }
        else {
            failureBlock?()
        }
    }
    
    func checkPermissionAccessForCalendar(_ successBlock: PermissionVoidBlock?, _ failureBlock: PermissionVoidBlock?, _ deniedBlock: PermissionVoidBlock?) {
        
        let authStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if authStatus == .authorized {
            successBlock?()
        }
        else if authStatus == .notDetermined {
            EKEventStore().requestAccess(to: .event) { (granted, error) in
                DispatchQueue.main.async {
                    if granted {
                        successBlock?()
                    }
                    else {
                        failureBlock?();
                    }
                }
            }
        }
        else if authStatus == .denied {
            deniedBlock?()
        }
        else {
            failureBlock?()
        }
    }
    
    func checkPermissionAccessMicrophone(_ successBlock: PermissionVoidBlock?, _ failureBlock: PermissionVoidBlock?, _ deniedBlock: PermissionVoidBlock?) {
        let authStatus = AVAudioSession.sharedInstance().recordPermission
        if authStatus == .granted {
            successBlock?()
        }
        else if authStatus == .denied {
            deniedBlock?()
        }
        else  {
            AVAudioSession.sharedInstance().requestRecordPermission { (grantied) in
                DispatchQueue.main.async {
                    if grantied {
                        successBlock?()
                    }
                    else {
                        failureBlock?()
                    }
                }
            }
        }
    }
    
    func checkPermissionAccessForLocation(_ successBlock: @escaping PermissionVoidBlock, _ failureBlock: @escaping PermissionVoidBlock, _ deniedBlock: @escaping PermissionVoidBlock) {
        
        if CLLocationManager.locationServicesEnabled() {
            self.copySuccesBlock = successBlock
            self.copyFailureBlock = failureBlock
            self.copyDeniedBlock = deniedBlock
            
            let locationManager = CLLocationManager.init()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        else {
            failureBlock()
        }
    }
   
}

extension PermissionsController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch (status) {
        case .authorizedAlways:
            manager.stopUpdatingLocation()
            self.copySuccesBlock?()
            break
        case .authorizedWhenInUse:
            manager.stopUpdatingLocation()
            self.copySuccesBlock?()
            break
        case .restricted:
            manager.stopUpdatingLocation()
            self.copyFailureBlock?()
            break
        case .denied:
            manager.stopUpdatingLocation()
            self.copyDeniedBlock?()
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager delegate didFailed")
    }
    
}
