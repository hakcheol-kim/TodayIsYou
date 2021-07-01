//
//  PhotoManagerViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/14.
//

import UIKit
import SwiftyJSON
import Photos
import BSImagePicker
import UIImageViewAlignedSwift
protocol PhotoManagerViewControllerDelegate {
    func didFinishChangePhotoSetting()
}
class PhotoManagerViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnAddPhoto: CButton!
    @IBOutlet weak var btnCheckTerm: UIButton!
    @IBOutlet weak var btnShowTerm: UIButton!
    var type:PhotoManageType = .normal
    var delegate: PhotoManagerViewControllerDelegate?
    
    var listData:[JSON] = []
    static func instantiate(with type:PhotoManageType) -> PhotoManagerViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoManagerViewController") as! PhotoManagerViewController
        vc.type = type
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, NSLocalizedString("activity_txt374", comment: "내 사진 관리"), #selector(actionNaviBack))
        
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        
        btnCheckTerm.isSelected = true
        reqeustGetMyPhotoList()
        btnCheckTerm.titleLabel?.numberOfLines = 0
        
        collectionView.cr.addHeadRefresh { [weak self] in
            self?.reqeustGetMyPhotoList()
        }
        if let ivCirclePluse = btnAddPhoto.viewWithTag(200) as? UIImageView {
            ivCirclePluse.layer.cornerRadius = ivCirclePluse.bounds.height/2;
        }
    }
    
    func reqeustGetMyPhotoList() {
        ApiManager.ins.requestGetMyPhotos(param: ["user_id":ShareData.ins.myId]) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            let result = response["result"].arrayValue
            
            if isSuccess == "01" {
                self.listData.removeAll()
                self.listData.append(contentsOf: result)
 
                if self.listData.count > 0 {
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                }
                else {
                    self.collectionView.isHidden = true
                }
                self.collectionView.cr.endHeaderRefresh()
            }
            else {
                self.collectionView.isHidden = true
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnCheckTerm {
            sender.isSelected = !sender.isSelected
        }
        else if sender == btnShowTerm {
            ApiManager.ins.requestServiceTerms(mode: "yk8") { (response) in
                let yk = response["yk"].stringValue
                if yk.isEmpty == false {
                    let vc = TermsViewController.init()
                    vc.content = yk
                    vc.type = .nomarl
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.showErrorToast(response)
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
        else if sender == btnAddPhoto {
            if btnCheckTerm.isSelected == false {
                self.showToast(NSLocalizedString("activity_txt375", comment: "사용자 제작 콘텐츠(UGC) 등록 약관에 동의 하세요."))
                return
            }
            
            var alertStyle = UIAlertController.Style.actionSheet
            if UIDevice.current.userInterfaceIdiom == .pad {
                alertStyle = .alert
            }
            let alert = UIAlertController(title:nil, message: nil, preferredStyle: alertStyle)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("photo_take_camera", comment: "카메라로 사진 촬영하기"), style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.showCameraPicker(.camera)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("photo_take_gallery", comment: "갤러리에서 사진 가져오기"), style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.showCameraPicker(.photoLibrary)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("activity_txt479", comment: "취소"), style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func showCameraPicker(_ sourceType: UIImagePickerController.SourceType) {
         let picker = CImagePickerController.init() { (orig, crop) in
            guard let orig = orig, let crop = crop else {
                return
            }
            print("== orig: \(orig), crop:\(crop)")
            self.showPhotoUsingAlert(orig, crop)
        }
        
        picker.sourceType = sourceType
        self.present(picker, animated: true, completion: nil)
    }
    
    func showPhotoUsingAlert(_ orig:UIImage, _ crop: UIImage) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) { [weak self] in
            let vc = CAlertViewController.init(type: .alert, title: NSLocalizedString("activity_txt378", comment: "이미지 검증/등록 신청"), message:NSLocalizedString("layout_txt94", comment: "*선택 사항이 동시에 모두 등록 가능합니다."), actions: nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil);
                
                if (index == 1) {
                    var param:[String:Any] = [:]
                    for i in 0..<vcs.arrBtnCheck.count {
                        let btn = vcs.arrBtnCheck[i]
                        if i == 0 {
                            if btn.isSelected == true {
                                param["image_cam_reservation"] = true
                            }
                            else {
                                param["image_cam_reservation"] = false
                            }
                        }
                        else if i == 1 {
                            if btn.isSelected == true {
                                param["image_talk_reservation"] = true
                            }
                            else {
                                param["image_talk_reservation"] = false
                            }
                        }
                        else {
                            if btn.isSelected == true {
                                param["image_profile_reservation"] = true
                            }
                            else {
                                param["image_profile_reservation"] = false
                            }
                        }
                    }
                    
                    param["user_id"] = ShareData.ins.myId
                    param["user_file"] = crop
                    
                    ApiManager.ins.requestRegistPhoto(param: param) { (res) in
                        let isSuccess = res["isSuccess"].stringValue
                        if isSuccess == "01" {
                            self?.view.makeToast(NSLocalizedString("activity_txt356", comment: "등록완료!!"))
                            self?.reqeustGetMyPhotoList()
                        }
                        else {
                            self?.showErrorToast(res)
                        }
                        
                    } failure: { (error) in
                        self?.showErrorToast(error)
                    }
                }
            }
            vc.addAction(.check, NSLocalizedString("layout_txt91", comment: "프로필 이미지에 등록"), nil, RGB(230, 100, 100), true)
            vc.addAction(.check, NSLocalizedString("layout_txt92", comment: "영상톡 이미지에 등록"), nil, RGB(230, 100, 100), true)
            vc.addAction(.check, NSLocalizedString("layout_txt93", comment: "일반톡 이미지에 등록"), nil, RGB(230, 100, 100), true)
            vc.addAction(.cancel, NSLocalizedString("activity_txt479", comment: "취소"))
            vc.addAction(.ok, NSLocalizedString("activity_txt478", comment: "확인"))
            vc.iconImg = UIImage(named: "ico_app_80")
            vc.fontMsg = UIFont.systemFont(ofSize: 13)
            vc.reloadUI()
            self?.present(vc, animated: true, completion: nil)
        }
    }
    
    func requestChangePhotoTalk(_ param:[String:Any]) {
        ApiManager.ins.requestChangePhotoTalk(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                if let delegate = self.delegate {
                    delegate.didFinishChangePhotoSetting()
                }
                appDelegate.window?.makeToast(NSLocalizedString("activity_txt356", comment: "등록완료!!"))
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }
    }
    func requestChangeMyPhoto(_ param:[String:Any]) {
        ApiManager.ins.requestModifyMyPhoto(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                if let delegate = self.delegate {
                    delegate.didFinishChangePhotoSetting()
                }
                appDelegate.window?.makeToast(NSLocalizedString("activity_txt356", comment: "등록완료!!"))
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.showErrorToast(res)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    func requestDeleteMyPhoto(_ param:[String:Any]) {
        ApiManager.ins.requestDeleteMyPhoto(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.reqeustGetMyPhotoList()
            }
            else {
                self.showErrorToast(res)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
}

extension PhotoManagerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImgColCell.identifier, for: indexPath) as? ImgColCell else {
            return UICollectionViewCell()
        }
        
        let item = listData[indexPath.row]
        let user_id = item["user_id"].stringValue
        let user_img = item["user_img"].stringValue
        let view_yn = item["view_yn"].stringValue
        
        cell.ivThumb.image = Gender.defaultImg(ShareData.ins.mySex.rawValue)
        if let url = Utility.thumbnailUrl(user_id, user_img) {
            cell.ivThumb.setImageCache(url)
        }
        if view_yn == "Y" {
            cell.btnState.setTitle(NSLocalizedString("activity_txt41", comment: "검증완료"), for: .normal)
            cell.btnState.setTitleColor(RGB(255, 0, 0), for: .normal)
        }
        else {
            cell.btnState.setTitle(NSLocalizedString("layout_txt89", comment: "검증중"), for: .normal)
            cell.btnState.setTitleColor(RGB(255, 255, 0), for: .normal)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 3*4)/3
        let height = 1.2*width
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let view_yn = item["view_yn"].stringValue
        
        if view_yn == "N" {
            self.showToast(NSLocalizedString("activity_txt43", comment: "검증완료 후 등록 삭제 보기가 가능 합니다!!"))
        }
        else if type == .photo {
            
            let user_id = item["user_id"].stringValue
            let user_img = item["user_img"].stringValue
            let seq = item["seq"].numberValue
            
            guard let url = Utility.thumbnailUrl(user_id, user_img) else {
                return
            }
            
            let vc = CAlertViewController.init(type: .alert, title: NSLocalizedString("activity_txt422", comment: "사진 등록, 삭제, 보기"), message:nil , actions: nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                
                if index == 1 {
                    let param = ["seq":seq]
                    self.requestDeleteMyPhoto(param)
                }
                else if index == 2 {
                    self.showPhoto(imgUrls: [url])
                }
                else if index == 3, vcs.arrBtnCheck.count > 0 {
                    var param:[String:Any] = [:]
                    guard let btn = vcs.arrBtnCheck.first else {
                        return
                    }
                    
                    if btn.isSelected == true {
                        param["user_id"] = ShareData.ins.myId
                        param["user_file"] = item["user_img"].stringValue
                        param["contents"] = ""
                        self.requestChangePhotoTalk(param)
                    }
                    else {
                        param["user_id"] = ShareData.ins.myId
                        param["user_file"] = item["user_img"].stringValue
                        param["image_profile_save"] = "false"
                        param["image_cam_save"] = "false"
                        param["image_talk_save"] = "false"
                        param["image_photo_save"] = "false"
                        
                        self.requestChangeMyPhoto(param)
                    }
                }
            }
            vc.addAction(.check, NSLocalizedString("layout_txt99", comment: "포토톡 사진 추가 등록"), nil, RGB(230, 100, 100), true)
            
            vc.addAction(.cancel, NSLocalizedString("activity_txt479", comment: "취소"))
            vc.addAction(.normal, NSLocalizedString("activity_txt55", comment: "삭제"))
            vc.addAction(.normal, NSLocalizedString("activity_txt424", comment: "보기"))
            vc.addAction(.ok, NSLocalizedString("activity_txt478", comment: "확인"))
            vc.iconImgName = url
            vc.fontMsg = UIFont.systemFont(ofSize: 13)
            vc.reloadUI()
            self.present(vc, animated: true, completion: nil)
        }
        else {
            let user_id = item["user_id"].stringValue
            let user_img = item["user_img"].stringValue
            let seq = item["seq"].numberValue
            
            guard let url = Utility.thumbnailUrl(user_id, user_img) else {
                return
            }
            
            let vc = CAlertViewController.init(type: .alert, title: NSLocalizedString("activity_txt422", comment: "사진 등록, 삭제, 보기"), message:NSLocalizedString("layout_txt100", comment: "*상황에 맞도록 선택해주세요.") , actions: nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                
                if index == 1 {
                    let param = ["seq":seq]
                    self.requestDeleteMyPhoto(param)
                }
                else if index == 2 {
                    self.showPhoto(imgUrls: [url])
                }
                else if index == 3, vcs.arrBtnCheck.count > 0 {
                    var param:[String:Any] = [:]
                    param["user_file"] = item["user_img"].stringValue
                    param["user_id"] = ShareData.ins.myId
                   
                    for i in 0..<vcs.arrBtnCheck.count {
                        let btn = vcs.arrBtnCheck[i]
                        if i == 0 {
                            param["image_profile_save"] = (btn.isSelected ? "true": "false")
                        }
                        else if i == 1 {
                            param["image_cam_save"] = (btn.isSelected ? "true":"false")
                        }
                        else {
                            param["image_talk_save"] = (btn.isSelected ? "true": "false")
                        }
                    }
                    param["image_photo_save"] = "false"
                    self.requestChangeMyPhoto(param)
                }
            }
            
            if type == .cam {
                vc.addAction(.check, NSLocalizedString("layout_txt96", comment: "프로필 사진 변경 등록"), nil, RGB(230, 100, 100), false)
                vc.addAction(.check, NSLocalizedString("layout_txt97", comment: "영상톡 사진 변경 등록"), nil, RGB(230, 100, 100), true)
                vc.addAction(.check, NSLocalizedString("layout_txt98", comment: "일반톡 사진 변경 등록"), nil, RGB(230, 100, 100), false)
            }
            else if type == .talk {
                vc.addAction(.check, NSLocalizedString("layout_txt96", comment: "프로필 사진 변경 등록"), nil, RGB(230, 100, 100), false)
                vc.addAction(.check, NSLocalizedString("layout_txt97", comment: "영상톡 사진 변경 등록"), nil, RGB(230, 100, 100), false)
                vc.addAction(.check, NSLocalizedString("layout_txt98", comment: "일반톡 사진 변경 등록"), nil, RGB(230, 100, 100), true)
            }
            else if type == .profile {
                vc.addAction(.check, NSLocalizedString("layout_txt96", comment: "프로필 사진 변경 등록"), nil, RGB(230, 100, 100), true)
                vc.addAction(.check, NSLocalizedString("layout_txt97", comment: "영상톡 사진 변경 등록"), nil, RGB(230, 100, 100), false)
                vc.addAction(.check, NSLocalizedString("layout_txt98", comment: "일반톡 사진 변경 등록"), nil, RGB(230, 100, 100), false)
            }
            else {
                vc.addAction(.check, NSLocalizedString("layout_txt96", comment: "프로필 사진 변경 등록"), nil, RGB(230, 100, 100), true)
                vc.addAction(.check, NSLocalizedString("layout_txt97", comment: "영상톡 사진 변경 등록"), nil, RGB(230, 100, 100), true)
                vc.addAction(.check, NSLocalizedString("layout_txt98", comment: "일반톡 사진 변경 등록"), nil, RGB(230, 100, 100), true)
            }
            
            vc.addAction(.cancel, NSLocalizedString("activity_txt479", comment: "취소"))
            vc.addAction(.normal, NSLocalizedString("activity_txt55", comment: "삭제"))
            vc.addAction(.normal, NSLocalizedString("activity_txt424", comment: "보기"))
            vc.addAction(.ok, NSLocalizedString("activity_txt478", comment: "확인"))
            
            vc.iconImgName = url
            vc.fontMsg = UIFont.systemFont(ofSize: 13)
            vc.reloadUI()
            self.present(vc, animated: true, completion: nil)
        }
        
    }
}
