//
//  PhotoListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SwiftyJSON

class PhotoListViewController: BaseViewController {
    @IBOutlet weak var btnJim: UIButton!
    @IBOutlet weak var segSort: UISegmentedControl!
    @IBOutlet weak var segGender: UISegmentedControl!
    @IBOutlet weak var lbNotice: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "PhotoColCell", bundle: nil), forCellWithReuseIdentifier: "PhotoColCell")
        }
    }
    
    var listData: [JSON] = []
    var pageNum: Int = 1
    var pageEnd: Bool = false
    var canRequest = true
    var searchSex:Gender = ShareData.ins.mySex.transGender()
    var searchTag: String = "인기"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segSort.layer.borderWidth = 1;
        segSort.layer.borderColor = RGB(230, 100, 100).cgColor
        segGender.layer.borderWidth = 1;
        segGender.layer.borderColor = RGB(230, 100, 100).cgColor
        
        segSort.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : RGB(230, 100, 100)], for: .normal)
        segSort.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        
        segGender.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : RGB(230, 100, 100)], for: .normal)
        segGender.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        btnJim.layer.cornerRadius = 4;
        lbNotice.layer.cornerRadius = 4;
        
        let layout = CFlowLayout.init()
        layout.numberOfColumns = 3
        layout.lineSpacing = 2
        layout.secInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        collectionView.collectionViewLayout = layout
        layout.delegate = self
        
        collectionView.cr.addHeadRefresh { [weak self] in
            self?.dataRest()
        }
        
        if searchTag == "최신" {
            segSort.selectedSegmentIndex = 1
        }
        if searchSex == .femail {
            segGender.selectedSegmentIndex = 1
        }
        segSort.setTitle(NSLocalizedString("layout_txt103", comment: "인기"), forSegmentAt: 0)
        segSort.setTitle(NSLocalizedString("layout_txt104", comment: "최신"), forSegmentAt: 1)
        
        segGender.setTitle(NSLocalizedString("root_display_txt21", comment: "남"), forSegmentAt: 0)
        segGender.setTitle(NSLocalizedString("root_display_txt20", comment: "여"), forSegmentAt: 1)
        
        self.dataRest()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.ins.mainViewCtrl.updateNaviPoint()
    }
    func dataRest() {
        pageNum = 1
        pageEnd = false
        requestPhotoList()
        if listData.count > 0 {
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    func addData() {
        requestPhotoList()
    }
    
    func requestPhotoList() {
        if pageEnd == true {
            return
        }
        
        var param: [String:Any] = [:]
        param["user_id"] = ShareData.ins.myId
        param["pageNum"] = pageNum
        param["search_photo_sex"] = searchSex.rawValue
        param["search_photo_top"] = searchTag
        
        ApiManager.ins.requestPhotoList(param: param) { (resonse) in
            self.canRequest = true
            let result = resonse["result"].arrayValue
            let isSuccess = resonse["isSuccess"].stringValue
            if isSuccess == "01" {
                if result.count == 0 {
                    self.pageEnd = true
                }
                else {
                    if self.pageNum == 1 {
                        self.listData = result
                    }
                    else {
                        self.listData.append(contentsOf: result)
                    }
                }
                
                self.collectionView.cr.endHeaderRefresh()
                if (self.listData.count > 0) {
                    
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                    
                    print("photo list count \(self.listData.count)")
                }
                else {
                    self.collectionView.isHidden = true
                }
                self.pageNum += 1
            }
            else {
                self.showErrorToast(resonse)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    
    
    @IBAction func segValueChanged(_ sender: UISegmentedControl) {
        if sender == segSort {
            self.searchTag = "인기"
            if sender.selectedSegmentIndex == 1 {
                self.searchTag = "최신"
            }
        }
        else if sender == segGender {
            self.searchSex = .mail
            if sender.selectedSegmentIndex == 1 {
                self.searchSex = .femail
            }
        }
        self.dataRest()
    }
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        
    }
    
}
extension PhotoListViewController: UICollectionViewDataSource, UICollectionViewDelegate, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoColCell", for: indexPath) as! PhotoColCell
        
        let item = listData[indexPath.row]
        cell.configurationData(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        return  ceil(1.2*(collectionView.bounds.size.width/3))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = listData[indexPath.row]
        let vc = PhotoDetailViewController.instantiateFromStoryboard(.main)!
        vc.passData = item
        AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
    }
}
extension PhotoListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        if velocityY < 0 && offsetY > contentH && canRequest == true {
            canRequest = false
            self.addData()
        }
    }
}
