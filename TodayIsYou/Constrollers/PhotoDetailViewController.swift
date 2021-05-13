//
//  PhotoDetailViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/29.
//

import UIKit
import SwiftyJSON
import UIImageViewAlignedSwift
import Lightbox

var maxShowPhoto:Int = 2
class PhotoDetailColCell: UICollectionViewCell {
    static let identifier = "PhotoDetailColCell"
    
    @IBOutlet weak var ivThumb: UIImageViewAligned!
    var visuableEffectView: UIVisualEffectView!
    var animator: UIViewPropertyAnimator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    fileprivate func setupVisualEffectBlur() {
        if let visuableEffectView = self.viewWithTag(1000) as? UIVisualEffectView {
            visuableEffectView.removeFromSuperview()
        }
        self.visuableEffectView = UIVisualEffectView()
        self.addSubview(self.visuableEffectView)
        visuableEffectView.tag = 1000
        visuableEffectView.isUserInteractionEnabled = false
        self.visuableEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.visuableEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.visuableEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.visuableEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.visuableEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        if animator != nil {
            animator.stopAnimation(true)
            animator.finishAnimation(at: .current)
            animator = nil
        }
        
        self.animator = UIViewPropertyAnimator(duration: 3, curve: .linear)
        self.animator.addAnimations {
            self.visuableEffectView.effect = UIBlurEffect(style: .regular)
        }
    }
    
    func configurationData(_ data:JSON, _ indexPath:IndexPath) {
        let user_id = data["user_id"].stringValue
        let img_name = data["img_name"].stringValue
//        let img_view = data["img_view"].stringValue
        
        ivThumb.image = nil
        if let url = Utility.thumbnailUrl(user_id, img_name) {
            ivThumb.setImageCache(url)
        }
        self.setupVisualEffectBlur()
        
        let count = 3*indexPath.section + indexPath.row;
        if count < maxShowPhoto {
            self.animator.fractionComplete = 0
        }
        else {
            self.animator.fractionComplete = 0.2
        }
    }
}

class PhotoDetailViewController: MainActionViewController {
    
    var passData:JSON!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnBack: UIButton!
    
    var listData:[JSON] = []
    var myheader: PhotoDetailReusableView?
    var checkInfo:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.register(UINib(nibName: "PhotoDetailReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PhotoDetailReusableView.identifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerId")
        
        let layout = SectionHeaderExapndFlowLayout()
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.minimumInteritemSpacing = 2
        collectionView.collectionViewLayout = layout
        
        self.checkPhotoDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if listData.count > 0 {
            collectionView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func checkPhotoDetail() {
        let seq = passData["seq"].stringValue
        let user_id = passData["user_id"].stringValue
        let param = ["my_user_id":ShareData.ins.myId, "user_id": user_id, "seq":seq]
    
        ApiManager.ins.requestPhotoDetailCheck(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.checkInfo = res
                let end_date = res["end_date"].stringValue
                if end_date.isEmpty == false {
                    self.myheader?.lbMsg.text = "\(end_date) 까지 보기 가능"
                }
                self.requestPhotoDetailList()
            }
            else if isSuccess == "00" {
                self.showToast("포인트가 없습니다.")
            }
            else {
                self.showErrorToast(res)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }

    }
    func requestPhotoDetailList() {
        let seq = passData["seq"].stringValue
        let param = ["board_key":seq]
        ApiManager.ins.requestPhotoDetailList(param: param) { (response) in
            let isSuccess = response["isSuccess"].stringValue
            let result = response["result"].arrayValue
            if isSuccess == "01" {
                self.listData = result
                self.collectionView.reloadData()
            }
            else {
                self.showErrorToast(response)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoDetailColCell.identifier, for: indexPath) as? PhotoDetailColCell else {
            return UICollectionViewCell()
        }
        let data = listData[indexPath.row]
        cell.configurationData(data, indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.size.width - 4*3)/3
        let height = 1.2*width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            self.myheader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoDetailReusableView.identifier, for: indexPath) as? PhotoDetailReusableView
            self.myheader!.configurationData(passData)
            
            self.myheader!.didClickedClosure = {(selItem, actionIndex) ->Void in
                guard let selItem = selItem else {
                    return
                }
                let user_id = selItem["user_id"].stringValue
                
                if actionIndex == 0 {
                    let seq = selItem["seq"].stringValue
                    if user_id.isEmpty == true || seq.isEmpty == true {
                        return
                    }
                    
                    let param = ["my_user_id":ShareData.ins.myId, "user_id":user_id, "seq": seq]
                    
                    ApiManager.ins.requestGoodPhotoPlus(param: param) { (res) in
                        let isSuccess = res["isSuccess"].stringValue
                        if isSuccess == "01" {
                            self.showToast("좋아요!!")
                        }
                        else if isSuccess == "02" {
                            self.showToast("좋아요는 1회만 가능합니다!!")
                        }
                        else {
                            self.showToast("등록 에러!!")
                        }
                    } failure: { (error) in
                        self.showErrorToast(error)
                    }
                }
                else if actionIndex == 1 {
                    self.selUser = selItem
                    self.checkTalk()
                }
            }
            return self.myheader!
        }
        else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerId", for: indexPath)
            return footer
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.bounds.width, height: 500)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .init(width: view.bounds.width, height: (view.bounds.height-500))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = listData[indexPath.row];
        
        var end_date = checkInfo["end_date"].stringValue
        let index = 3*indexPath.section + indexPath.row
        let photoDayPoint = ShareData.ins.dfsGet(DfsKey.photoDayPoint) as! NSNumber
        
        end_date = "3543"
        if index < maxShowPhoto { //전체 보기
            let user_id = item["user_id"].stringValue
            let img_name = item["img_name"].stringValue
            guard let url = Utility.originImgUrl(user_id, img_name) else {
                return
            }
            self.showPhoto(imgUrls: [url])
        }
        else if end_date.isEmpty == true && "남" == ShareData.ins.mySex.rawValue && photoDayPoint.intValue > 0 {
            let msg = "전체사진을 보기위해 \(photoDayPoint.stringValue) 포인트가 소모되며\n24시간동안 볼수 있습니다.\n결제하시겠습니까?"
            CAlertViewController.show(type:.alert, title:"전체사진보기", message: msg, actions: [.cancel, .ok]) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                if index == 1 {
                    //포토 전체보기 결재 진행
                }
            }
        }
        else {
            CAlertViewController.show(type:.alert, title:"전체사진보기", message: "전체 사진을 볼수 있습니다.", actions: [.cancel, .ok]) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                if index == 1 {
                    var imgUrls:[String] = []
                    for item in self.listData {
                        let user_id = item["user_id"].stringValue
                        let img_name = item["img_name"].stringValue
                        if let url = Utility.originImgUrl(user_id, img_name) {
                            imgUrls.append(url)
                        }
                    }
                    if imgUrls.isEmpty == false {
                        self.showPhoto(imgUrls: imgUrls)
                    }
                }
            }
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let contentOffsetY = scrollView.contentOffset.y
//        if contentOffsetY > 0 {
//            myheader?.animator.fractionComplete = 0.0
//            return
//        }
//        myheader?.animator.fractionComplete =  abs(contentOffsetY)/100.0
//    }
}

