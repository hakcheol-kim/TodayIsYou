//
//  MainViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SideMenu

class MainViewController: BaseViewController {
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet var btnTabs: [UIButton]!
    @IBOutlet weak var containerView: UIView!
    
    let colorTabBtnNor = RGB(248, 24, 148)
    let colorTabBtnSel = RGB(253, 165, 15)
    var oldSelIndex: Int = -1
    var selectedVc: UIViewController?
    var videoSortType: SortedType = .total
    var videoListType: ListType = .table
    
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
                    let vc = storyboard?.instantiateViewController(identifier: "CamTalkListViewController") as! CamTalkListViewController
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
                    let vc = storyboard?.instantiateViewController(identifier: "MssageListViewController") as! MssageListViewController
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
        CNavigationBar.drawRight(self, nil, "0 S", TAG_NAVI_S_COINT, nil)
        CNavigationBar.drawRight(self, nil, "0 P", TAG_NAVI_P_COINT, nil)
       
        tabView.addShadow(offset: CGSize(width: 1, height: 1), color: RGBA(0, 0, 0, 0.3), raduius: 3, opacity: 0.3)
        
        btnTabs = btnTabs.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        
        for btn in btnTabs {
            btn.addTarget(self, action: #selector(onclickedBtnActions(_:)), for: .touchUpInside)
        }
        self.selIndex = 0
        
        setupSideMenu()
        updateMenus()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
    }
    
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (AppDelegate.ins.window?.rootViewController?.view)!)
    }
    @IBAction func onclickedBtnActions(_ sender:UIButton) {
        if sender.tag == 1000 {
            guard let left = SideMenuManager.default.leftMenuNavigationController else { return }
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (self.navigationController?.view)!, forMenu: .right)
            self.present(left, animated: true, completion: nil)
        }
        else if sender.tag == TAG_NAVI_POINT {
            guard let vc = storyboard?.instantiateViewController(identifier: "PointChargeViewController") as? PointChargeViewController else {
                return
            }
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if btnTabs.contains(sender) == true {
            self.selIndex = sender.tag
        }
    }
   
    private func updateMenus() {
        let settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
    }
    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
        let modes: [SideMenuPresentationStyle] = [.menuSlideIn, .viewSlideOut, .viewSlideOutMenuIn, .menuDissolveIn]
        return modes[0]
    }
    private func makeSettings() -> SideMenuSettings {
        
        let presentationStyle = selectedPresentationStyle()
        presentationStyle.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "img_back2.jpg"))
        presentationStyle.menuStartAlpha = CGFloat(1.0)
        presentationStyle.menuScaleFactor = CGFloat(1.0)
        presentationStyle.onTopShadowOpacity = 0.3
        presentationStyle.presentingEndAlpha = CGFloat(0.2)
        presentationStyle.presentingScaleFactor = CGFloat(1)

        var settings = SideMenuSettings()
        settings.allowPushOfSameClassTwice = false
        settings.presentationStyle = .menuSlideIn
        settings.menuWidth = min(view.frame.width, view.frame.height) * CGFloat(0.55)
        let styles:[UIBlurEffect.Style?] = [nil, .dark, .light, .extraLight]
        settings.blurEffectStyle = styles[0]
        settings.statusBarEndAlpha = 0

        return settings
    }
    
    func updateNaviPoint() {
        guard let navibar = self.navigationController?.navigationBar, let btn = navibar.viewWithTag(TAG_NAVI_P_COINT) as? UIButton else {
            return
        }
        
        var point = ""
        if let myPoint = ShareData.ins.myPoint {
            point = "\(myPoint.stringValue.addComma()) P"
        }
        else {
            point = "0 P"
        }
        btn.setTitle(point, for: .normal)
        let size = btn.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: btn.bounds.height))
        btn.frame = CGRect(origin: btn.frame.origin, size: size)
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
