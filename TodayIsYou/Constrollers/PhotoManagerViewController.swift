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

class PhotoManagerViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnAddPhoto: CButton!
    @IBOutlet weak var btnCheckTerm: UIButton!
    @IBOutlet weak var btnShowTerm: UIButton!
    
    var listData:[JSON] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, "내 사진 관리", #selector(actionNaviBack))
        collectionView.register(UINib(nibName: "ImageColCell", bundle: nil), forCellWithReuseIdentifier: "ImageColCell")
        
        let layout = CFlowLayout.init()
        layout.numberOfColumns = 3
        layout.delegate = self
        layout.lineSpacing = 2
        layout.secInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        btnCheckTerm.isSelected = true
        reqeustGetMyPhotoList()
    }
    
    func reqeustGetMyPhotoList() {
        ApiManager.ins.requestGetMyPhotos(param: ["user_id":ShareData.instance.userId]) { (response) in
            let isSuccess = response?["isSuccess"].stringValue
            let result = response?["result"].arrayValue
            if let result = result, isSuccess == "01" {
                self.listData = result
                if self.listData.count > 0 {
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                }
                else {
                    self.collectionView.isHidden = true
                }
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
                let isSuccess = response?["isSuccess"].stringValue
                if isSuccess == "01", let yk = response?["yk"].stringValue {
                    guard let vc = self.storyboard?.instantiateViewController(identifier: "TermsViewController") as? TermsViewController else { return }
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
            let alert = UIAlertController.init(title:nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.init(title: "카메라로 사진 촬영하기", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.showCameraPicker(.camera)
            }))
            alert.addAction(UIAlertAction.init(title: "갤러리에서 사진 가져오기", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.showCameraPicker(.photoLibrary)
            }))
            alert.addAction(UIAlertAction.init(title: "취소", style: .destructive, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showCameraPicker(_ sourceType: UIImagePickerController.SourceType) {
        let picker = CImagePickerController.init(sourceType) { (orig, crop) in
            guard let orig = orig else {
                return
            }
            if let crop = crop {
                print("== orig: \(orig), crop:\(crop)")
            }
            else {
                print("== orig: \(orig)")
            }
        }
        self.present(picker, animated: true, completion: nil)
        
//            let picker = ImagePickerController()
//            picker.settings.selection.max = 5
//            picker.settings.theme.selectionStyle = .numbered
//            picker.settings.fetch.assets.supportedMediaTypes = [.image]
//            picker.settings.selection.unselectOnReachingMax = true
//
//            self.presentImagePicker(picker, select: nil, deselect: nil, cancel: nil) { (assets) in
//                print("Finished with selections: \(assets)")
//                picker.dismiss(animated: false)
//            }
    }
}

extension PhotoManagerViewController: UICollectionViewDelegate, UICollectionViewDataSource, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageColCell", for: indexPath) as! ImageColCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        return  ceil(1.2*(collectionView.bounds.size.width/3))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
