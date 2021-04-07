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
    
    var listData:[JSON] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, "포토 토크 등록", #selector(actionNaviBack))
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        
        let layout = CFlowLayout.init()
        layout.numberOfColumns = 3
        layout.lineSpacing = 2
        layout.secInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        collectionView.collectionViewLayout = layout
        layout.delegate = self
        
        requestPhotoTalkList()
    }
    func requestPhotoTalkList() {
        
    }
    @IBAction func onClickedBtnActions(_ sender: Any) {
        
    }
}

extension PhotoTalkWriteViewController: UICollectionViewDataSource, UICollectionViewDelegate, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoColCell
        
        cell.btnImgCnt.isHidden = true
        cell.btnHartCnt.isHidden = true
        cell.infoView.isHidden = true
        
        let item = listData[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        let width = (collectionView.bounds.width - 12)/3
        return width*1.2
    }
    
    
}
