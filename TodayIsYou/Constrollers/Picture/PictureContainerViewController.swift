//
//  PictureContainerViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/24.
//

import UIKit
enum PictureListType {
    case new, popular, rank
}

class PictureContainerViewController: BaseViewController {
    @IBOutlet weak var btnNotice: CButton!
    @IBOutlet var tabMenus: [CButton]!
    @IBOutlet weak var containerView: UIView!
    
    private var curTabMenu: PictureListType!
    private var oldTabMenu: PictureListType!
    private var selectedVc: UIViewController?
    var didScroll: ((_ direction:ScrollDirection, _ offsetY:CGFloat) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       tabMenus = tabMenus.sorted { btn1, btn2 in
            return btn1.tag < btn2.tag
        }
        
        let imgNor = UIImage.color(from: .appColor(.grayButtonBg))
        let imgSel = UIImage.color(from: .appColor(.appColor))
        let imgBlue = UIImage.color(from: .appColor(.naviLight))
        self.view.layoutIfNeeded()
        
        for (index, tabMenu) in tabMenus.enumerated() {
            tabMenu.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
            tabMenu.setBackgroundImage(imgNor, for: .normal)
            tabMenu.setBackgroundImage(imgSel, for: .selected)
            
            tabMenu.setTitleColor(.appColor(.gray125), for: .normal)
            tabMenu.setTitleColor(.appColor(.whiteText), for: .selected)
            tabMenu.titleLabel?.numberOfLines = 0
            tabMenu.titleLabel?.textAlignment = .center
            
            switch index {
            case 0:
                tabMenu.data = PictureListType.new
            case 1:
                tabMenu.data = PictureListType.popular
            case 2:
                tabMenu.data = PictureListType.rank
            default:
                tabMenu.data = nil
                tabMenu.setBackgroundImage(imgBlue, for: .normal)
                tabMenu.setTitleColor(.appColor(.whiteText), for: .normal)
            }
            tabMenu.addFlexableHeightConstraint()
        }
        tabMenus.first?.sendActions(for: .touchUpInside)
        btnNotice.setBackgroundImage(UIImage.color(from: UIColor.appColor(.grayBg241)), for: .normal)
        btnNotice.titleLabel?.numberOfLines = 0
        btnNotice.addFlexableHeightConstraint()
    }
    
    func addChildView() {
        if curTabMenu == .new {
            self.btnNotice.isHidden = true
            let viewModel = PictureListViewModel(category: 1)
            let vc = PictureListViewController.initWithViewModel(viewModel)
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            vc.didScroll = {(direction, offsetY) ->(Void) in
                self.didScroll?(direction, offsetY)
            }
            self.selectedVc = vc
        }
        else if curTabMenu == .popular {
            self.btnNotice.isHidden = true
            let viewModel = PictureListViewModel(category: 2)
            let vc = PictureListViewController.initWithViewModel(viewModel)
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            vc.didScroll = {(direction, offsetY) ->(Void) in
                self.didScroll?(direction, offsetY)
            }
            self.selectedVc = vc
        }
        else if curTabMenu == .rank {
            self.btnNotice.isHidden = false
            let viewModel = PictureRankViewModel()
            let vc = PictureRankViewController.initWithViewModel(viewModel)
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            vc.didScroll = {(direction, offsetY) ->(Void) in
                self.didScroll?(direction, offsetY)
            }
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
            if (sender.tag == 4) {
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
                self.curTabMenu = sender.data as! PictureListType
                self.changeTabMenu()
            }
        }
    }
}
