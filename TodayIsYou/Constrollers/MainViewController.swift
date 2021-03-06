//
//  MainViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit

class MainViewController: BaseViewController {
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet var btnTabs: [UIButton]!
    @IBOutlet weak var containerView: UIView!
    
    let colorTabBtnNor = RGB(248, 24, 148)
    let colorTabBtnSel = RGB(253, 165, 15)
    var oldSelIndex: Int = -1
    var selectedVc: UIViewController?
    var videoSortType: SortedType = .total
    var videoListType: ListType = .collection
    
    var selIndex:Int = 0 {
        didSet {
            for btn in btnTabs {
                if let ivIcon = btn.viewWithTag(100) as? UIImageView {
                    ivIcon.image = ivIcon.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                    if (selIndex == btn.tag) {
                        ivIcon.tintColor = colorTabBtnSel
                    }
                    else {
                        ivIcon.tintColor = colorTabBtnNor
                    }
                    
                }
                if let lbTitle = btn.viewWithTag(101) as? UILabel {
                    if selIndex == btn.tag {
                        lbTitle.textColor = colorTabBtnSel
                    }
                    else {
                        lbTitle.textColor = colorTabBtnNor
                    }
                }
            }
            
            if oldSelIndex != selIndex {
                if let selectedVc = selectedVc {
                    self.myRemoveChildViewController(childViewController: selectedVc)
                }
                
                switch selIndex {
                case 0:
                    let vc = storyboard?.instantiateViewController(identifier: "VideoListViewController") as! VideoListViewController
                    vc.sortType = videoSortType
                    vc.listType = videoListType
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    
                    self.selectedVc = vc
                    break
                case 1:
                    
                    let vc = storyboard?.instantiateViewController(identifier: "TalkListViewController") as! TalkListViewController
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    
                    self.selectedVc = vc
                    break
                case 2:
                    let vc = storyboard?.instantiateViewController(identifier: "PhotoListViewController") as! PhotoListViewController
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    
                    self.selectedVc = vc
                    break
                case 3:
                    let vc = storyboard?.instantiateViewController(identifier: "RankListViewController") as! RankListViewController
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    self.selectedVc = vc
                    break
                case 4:
                    let vc = storyboard?.instantiateViewController(identifier: "NoteListViewController") as! NoteListViewController
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    
                    self.selectedVc = vc
                    break
                case 5:
                    let vc = storyboard?.instantiateViewController(identifier: "SettingViewController") as! SettingViewController
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    self.selectedVc = vc
                    break
                default:
                    
                    break
                }
                
            }
            oldSelIndex = selIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawLeftBarItem(self, UIImage(systemName: "text.justify"), "영상토크", 1000, #selector(onclickedBtnActions(_ :)))
        
        CNavigationBar.drawRight(self, UIImage(named: "point"), nil, TAG_NAVI_POINT, #selector(onclickedBtnActions(_:)))
        CNavigationBar.drawRight(self, nil, "0 S", 1001, nil)
        CNavigationBar.drawRight(self, nil, "2,000 P", 1002, nil)
       
        tabView.addShadow(offset: CGSize(width: 1, height: 1), color: RGBA(0, 0, 0, 0.3), raduius: 3, opacity: 0.3)
        
        btnTabs = btnTabs.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        
        for btn in btnTabs {
            btn.addTarget(self, action: #selector(onclickedBtnActions(_:)), for: .touchUpInside)
        }
        self.selIndex = 0
    }
    
    @IBAction func onclickedBtnActions(_ sender:UIButton) {
        if sender.tag == 1000 {
            
        }
        else if sender.tag == TAG_NAVI_POINT {
            
        }
        else if btnTabs.contains(sender) == true {
            self.selIndex = sender.tag
        }
    }
}
