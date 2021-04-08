//
//  PhotoTalkWriteViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/04.
//

import UIKit
import SwiftyJSON

class PhotoTalkWriteViewController: BaseViewController {
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var btnAddPhoto: CButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnLink: UIButton!
    
    var listData:[JSON] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "포토 토크 등록", #selector(actionNaviBack))
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        
        let attr = NSAttributedString.init(string: "사진 등록하고 적립, 환급받는 방법 알아보기", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        btnLink.setAttributedTitle(attr, for: .normal)
        
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        
        lbMsg.text = "사진은 검증된 사진만 등록합니다."
        if "남" == ShareData.ins.userSex.rawValue, let point = ShareData.ins.dfsObjectForKey(DfsKey.photoDayPoint) as? NSNumber, point.intValue > 0 {
            lbMsg.text = "사진은 검증된 사진만 등록 됩니다.\n사진 등록시 1일 1회 \(point.stringValue.addComma())P를 적립해 드립니다"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestGetMyPhotoTalk()
    }
    func requestGetMyPhotoTalk() {
        let param = ["user_id" : ShareData.ins.userId]
        ApiManager.ins.requestGetMyPhotoTalk(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                let result = res["result"].arrayValue
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
            }
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnLink {
            ApiManager.ins.requestServiceTerms(mode: "yk4") { (res) in
                let isSuccess = res["isSuccess"].stringValue
                let yk = res["yk"].stringValue
                if isSuccess == "01", yk.isEmpty == false {
                    let vc = TermsViewController.init()
                    vc.vcTitle = "안내"
                    vc.content = yk
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.showErrorToast(res)
                }
            } failure: { (err) in
                self.showErrorToast(err)
            }
        }
        else if sender == btnAddPhoto {
            let vc = PhotoManagerViewController.instantiate(with: .photo)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension PhotoTalkWriteViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImgColCell.identifier, for: indexPath) as? ImgColCell else {
            return UICollectionViewCell()
        }
        
        let item = listData[indexPath.row]
        let img_name = item["img_name"].stringValue
        let user_id = item["user_id"].stringValue
        
        if let url = Utility.thumbnailUrl(user_id, img_name) {
            cell.ivThumb.setImageCache(url: url, placeholderImgName: nil)
        }
        else {
            cell.ivThumb.image = UIImage(systemName: "person.fill")
        }
        cell.btnState.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12)/3
        let height = ceil(1.2*width)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        
        let vc = CAlertViewController.init(type: .alert, title: "삭제/보기", message: "이미지를 삭제 혹은 보기 가능합니다.", actions: nil) { (vcs, selIem, index) in
            vcs.dismiss(animated: true, completion: nil)
            if index == 0  {
                let seq = item["seq"].stringValue
                let param = ["seq": seq]
                ApiManager.ins.requestDeletePhotoTalk(param: param) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    if isSuccess == "01" {
                        self.requestGetMyPhotoTalk()
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } fail: { (err) in
                    self.showErrorToast(err)
                }

            }
            else if index == 1 {
                let img_name = item["img_name"].stringValue
                let user_id = item["user_id"].stringValue
                
                guard let url = Utility.thumbnailUrl(user_id, img_name) else {
                    return
                }
                self.showPhoto(imgUrls: [url])
            }
        }
        vc.addAction(.ok, "삭제")
        vc.addAction(.normal, "보기")
        present(vc, animated: true, completion: nil)
    }
    
}
