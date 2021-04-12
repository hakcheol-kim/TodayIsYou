//
//  PopupListViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/25.
//

import UIKit
import PanModal

enum PopupColType {
    case normal, gift
}

class PopupListColCell: UICollectionViewCell {
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class PopupCollectionListViewController: BaseViewController {
    
    @IBOutlet weak var svTitle: UIStackView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnClose: UIButton!
    
    var listData:[Any] = []
    var keys:[String]? = nil
    var type:PopupColType = .normal
    var vcTitle: Any?
    var fitHeight:CGFloat = 0
    
    var completion:((_ vcs: UIViewController, _ selItem:Any?, _ index:NSInteger) -> Void)?
    
    static func initWithType(_ type: PopupColType, _ title:Any?, _ data:[Any], _ keys:[String]?, completion:((_ vcs: UIViewController, _ selItem:Any?, _ index:NSInteger) -> Void)?) -> PopupCollectionListViewController {
        
        let vc = PopupCollectionListViewController.instantiateFromStoryboard(.main)!
        vc.completion = completion
        vc.listData = data
        vc.type = type
        vc.vcTitle = title
        vc.keys = nil
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        svTitle.isHidden = true
        if let vcTitle = vcTitle as? String {
            svTitle.isHidden = false
            lbTitle.text = vcTitle
        }
        else if let vcTitle = vcTitle as? NSAttributedString {
            svTitle.isHidden = false
            lbTitle.attributedText = vcTitle
        }
        
        btnClose.imageView?.contentMode = .scaleAspectFill
        self.btnClose.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
        self.view.layoutIfNeeded()
        
        let layout = CFlowLayout.init()
        if type == .gift {
            layout.numberOfColumns = 3
        }
        else {
            layout.numberOfColumns = 2
        }
        layout.lineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        
        self.collectionView.reloadData()
        self.view.layoutIfNeeded()
        
        self.fitHeight = self.collectionView.contentSize.height
        if self.svTitle.isHidden == false {
            self.fitHeight += self.svTitle.bounds.height
        }
        self.panModalSetNeedsLayoutUpdate()
    }
    
    @objc func onClickedBtnActions(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension PopupCollectionListViewController: UICollectionViewDelegate, UICollectionViewDataSource, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopupListColCell", for: indexPath) as? PopupListColCell else {
            return UICollectionViewCell()
        }
        if type == .gift {
            cell.ivIcon.isHidden = false
        }
        
        if let item = listData[indexPath.row] as? String {
            cell.lbTitle.text = item
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        return 101
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = listData[indexPath.row]
        self.completion?(self, item, indexPath.row)
    }
}
extension PopupCollectionListViewController: PanModalPresentable {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var panModalBackgroundColor: UIColor {
        return RGBA(0, 0, 0, 0.2)
    }
    var showDragIndicator: Bool {
        return false
    }
    var panScrollable: UIScrollView? {
        return self.collectionView
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(fitHeight)
    }
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(40)
    }
    
    var cornerRadius : CGFloat {
        return 16.0
    }
    var anchorModalToLongForm: Bool {
        return false
    }
}
