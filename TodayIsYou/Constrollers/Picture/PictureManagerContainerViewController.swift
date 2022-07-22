//
//  PictureManagerContainerViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/28.
//

import UIKit

enum PictureMangerTabMenu {
    case manger, earning, purchased
}

class PictureManagerContainerViewController: BaseViewController {
    @IBOutlet var tabMenus: [CButton]!
    @IBOutlet weak var containerView: UIView!
    
    private var curTabMenu: PictureMangerTabMenu!
    private var oldTabMenu: PictureMangerTabMenu!
    private var selectedVc: UIViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, NSLocalizedString("picture_setting_title", comment: "화보관리"), #selector(actionNaviBack))
        initUI()
    }
    
    private func initUI() {
        tabMenus = tabMenus.sorted(by: { btn1, btn2 in
            return btn1.tag < btn2.tag
        })
        
        let imgNor = UIImage.color(from: .appColor(.grayButtonBg))
        let imgSel = UIImage.color(from: .appColor(.appColor))
        let imgBlue = UIImage.color(from: .appColor(.naviLight))
        
        for (index, tabMenu) in tabMenus.enumerated() {
            tabMenu.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
            tabMenu.setBackgroundImage(imgNor, for: .normal)
            tabMenu.setBackgroundImage(imgSel, for: .selected)
            tabMenu.titleLabel?.numberOfLines = 0
            tabMenu.titleLabel?.textAlignment = .center
            
            tabMenu.setTitleColor(.appColor(.gray125), for: .normal)
            tabMenu.setTitleColor(.appColor(.whiteText), for: .selected)
            
            switch index {
            case 0:
                tabMenu.data = PictureMangerTabMenu.manger
            case 1:
                tabMenu.data = PictureMangerTabMenu.earning
            case 2:
                tabMenu.data = PictureMangerTabMenu.purchased
            default:
                tabMenu.data = nil
                tabMenu.setBackgroundImage(imgBlue, for: .normal)
                tabMenu.setTitleColor(.appColor(.whiteText), for: .normal)
            }
            tabMenu.setNeedsDisplay()
            tabMenu.addFlexableHeightConstraint()
        }
        tabMenus.first?.sendActions(for: .touchUpInside)
    }
    func addChildView() {
        if curTabMenu == .manger {
            let vc = PictureManagerListViewController.instantiateFromStoryboard(.picture)!
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            self.selectedVc = vc
        }
        else if curTabMenu == .earning {
            let vc = PictureMangerEarningViewController.instantiateFromStoryboard(.picture)!
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            self.selectedVc = vc
        }
        else if curTabMenu == .purchased {
            let vc = PictureMangerPurchasedViewController.instantiateFromStoryboard(.picture)!
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            self.selectedVc = vc
        }
    }
    func changeTabMenu() {
        if oldTabMenu != nil || oldTabMenu != curTabMenu {
            if let selectedVc = selectedVc {
                self.myRemoveChildViewController(childViewController: selectedVc)
            }
            self.addChildView()
            self.oldTabMenu = curTabMenu
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if let sender = sender as? CButton, tabMenus.contains(sender) {
            if sender.tag == 4 {
                let vc = PictureWkWebViewController.instantiateFromStoryboard(.picture)!
                vc.param = ["user_id" : ShareData.ins.myId]
                vc.vcTitle = NSLocalizedString("picture_regist_title", comment: "화보등록")
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            else {
                tabMenus.forEach { btn in
                    btn.isSelected = false
                }
                sender.isSelected = true
                self.curTabMenu = sender.data as! PictureMangerTabMenu
                self.changeTabMenu()
            }
        }
    }
}
