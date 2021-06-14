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
    @IBOutlet weak var floatRocket: CView!
    @IBOutlet weak var floatPlus: CView!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnRocket: UIButton!
    @IBOutlet weak var svItems: UIStackView!
    
    var oldSelIndex: Int = -1
    var selectedVc: UIViewController?
    
    var videoSortType: SortedType = SortedType.getSortType(ShareData.ins.mySex.transGender())
    var videoListType: ListType = .collection
    
    var selIndex:Int = 0 {
        didSet {
            for btn in btnTabs {
                if let ivIcon = btn.viewWithTag(100) as? UIImageView {
                    
                    if (selIndex == btn.tag) {
//                        ivIcon.tintColor = colorTabBtnSel
                        switch btn.tag {
                            case 0:
                                ivIcon.image = UIImage(named: "cam_call_over")
                                break
                            case 1:
                                ivIcon.image = UIImage(named: "talk_over")
                                break
                            case 2:
                                ivIcon.image = UIImage(named: "photo_over")
                                break
                            case 3:
                                ivIcon.image = UIImage(named: "rank_over")
                                break
                            case 4:
                                ivIcon.image = UIImage(named: "message_over")
                                break
                            case 5:
                                ivIcon.image = UIImage(named: "setting_over")
                                break
                            default:
                                break
                        }
                    }
                    else {
//                        ivIcon.tintColor = colorTabBtnNor
                        
                        switch btn.tag {
                            case 0:
                                ivIcon.image = UIImage(named: "cam_call")
                                break
                            case 1:
                                ivIcon.image = UIImage(named: "talk")
                                break
                            case 2:
                                ivIcon.image = UIImage(named: "photo")
                                break
                            case 3:
                                ivIcon.image = UIImage(named: "rank")
                                break
                            case 4:
                                ivIcon.image = UIImage(named: "message")
                                break
                            case 5:
                                ivIcon.image = UIImage(named: "setting")
                                break
                            default:
                                break
                        }
                    }
                    
                }
                if let lbTitle = btn.viewWithTag(101) as? UILabel {
                    if selIndex == btn.tag {
                        lbTitle.textColor = RGB(230, 100, 100)
                    }
                    else {
                        lbTitle.textColor = UIColor.label
                    }
                }
            }
            
            if oldSelIndex != selIndex {
                if let selectedVc = selectedVc {
                    self.myRemoveChildViewController(childViewController: selectedVc)
                }
                
                switch selIndex {
                case 0:
                    let vc = CamTalkListViewController.instantiateFromStoryboard(.main)!
                    vc.sortType = videoSortType
                    vc.listType = videoListType
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    self.selectedVc = vc
                    self.changeNaviTitle("activity_txt299".localized)
                    break
                case 1:
                    let vc = TalkListViewController.instantiateFromStoryboard(.main)!
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    self.selectedVc = vc
                    self.changeNaviTitle("activity_txt300".localized)
                    break
                case 2:
                    let vc = PhotoListViewController.instantiateFromStoryboard(.main)!
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    self.selectedVc = vc
                    self.changeNaviTitle("activity_txt301".localized)
                    break
                case 3:
                    let vc = RankListViewController.instantiateFromStoryboard(.main)!
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    self.selectedVc = vc
                    self.changeNaviTitle("activity_txt302".localized)
                    break
                case 4:
                    let vc = ChattingListViewController.instantiateFromStoryboard(.main)!
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    self.selectedVc = vc
                    self.changeNaviTitle("activity_txt303".localized)
                    break
                case 5:
                    let vc = SettingViewController.instantiateFromStoryboard(.main)!
                    self.myAddChildViewController(superView: containerView, childViewController: vc)
                    self.selectedVc = vc
                    self.changeNaviTitle("activity_txt306".localized)
                    break
                default:
                    break
                }
            }
            
            svItems.isHidden = true
            if selIndex == 0 {
                svItems.isHidden = false
                floatRocket.isHidden = false
                floatPlus.isHidden = false
            }
            else if selIndex == 1 || selIndex == 2 {
                svItems.isHidden = false
                floatRocket.isHidden = true
                floatPlus.isHidden = false
            }
            
            oldSelIndex = selIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawLeftBarItem(self, UIImage(systemName: "text.justify"), "activity_txt299".localized, TAG_NAVI_TITLE, #selector(onclickedBtnActions(_ :)))
        
        CNavigationBar.drawRight(self, nil, "0 P", TAG_NAVI_P_COINT, nil)
        CNavigationBar.drawRight(self, nil, "0 S", TAG_NAVI_S_COINT, nil)
        CNavigationBar.drawRight(self, UIImage(named: "point"), nil, TAG_NAVI_POINT, #selector(onclickedBtnActions(_:)))
       
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
        self.requestMyHomePoint()
        AppDelegate.ins.requestUpdateFcmToken()
        btnRocket.layer.cornerRadius = btnRocket.bounds.height/2
        btnPlus.layer.cornerRadius = btnPlus.bounds.height/2
        AppDelegate.ins.apptrakingPermissionCheck()
        AdbrixEvent.addEventLog(.login, ["user_id": ShareData.ins.myId, "user_name":ShareData.ins.myName, "user_sex":ShareData.ins.mySex.rawValue])
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUnReadMessageCount()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.updateNaviPoint()
        self.requestMyInfo()
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
    }
    
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
//        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (AppDelegate.ins.window?.rootViewController?.view)!)
    }
    @IBAction func onclickedBtnActions(_ sender:UIButton) {
        if sender.tag == TAG_NAVI_TITLE {
            guard let left = SideMenuManager.default.leftMenuNavigationController else { return }
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (self.navigationController?.view)!, forMenu: .right)
            self.present(left, animated: true, completion: nil)
        }
        else if sender.tag == TAG_NAVI_POINT {
            let vc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
            AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if btnTabs.contains(sender) == true {
            self.selIndex = sender.tag
        }
        else if sender == btnPlus {
            if selIndex == 0 {
                let vc = TalkWriteViewController.instant(withType: .cam)
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
            else if selIndex == 1 {
                let vc = TalkWriteViewController.instant(withType: .talk)
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
            else {
                let vc = PhotoTalkWriteViewController.instantiateFromStoryboard(.main)!
                AppDelegate.ins.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
        }
        else if sender == btnRocket {
            CAlertViewController.show(type: .alert, title: NSLocalizedString("activity_txt118", comment: "빠른 영상채팅 신청"), message: NSLocalizedString("activity_txt122", comment: "빠른 영상채팅 신청을 합니다."), actions: [.cancel, .ok]) { vcs, selItem, action in
                vcs.dismiss(animated: true, completion: nil)
                if action == 1 {
                    let vc = RandomCallViewController.instantiateFromStoryboard(.call)!
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
//                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
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
    func changeNaviTitle(_ title: String) {
        guard let navibar = self.navigationController?.navigationBar, let btnMenu = navibar.viewWithTag(TAG_NAVI_TITLE) as? UIButton else {
            return
        }
        btnMenu.setTitle(title, for: .normal)
        
        var width: CGFloat = btnMenu.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: btnMenu.frame.size.height)).width
        if width > 250 {
            width = 250
        }
        btnMenu.frame = CGRect.init(x: 0, y: 0, width: width + btnMenu.titleEdgeInsets.left, height: btnMenu.frame.size.height)
    }
    
    func updateNaviPoint() {
        var pointP = "0 P"
        if let myPoint = ShareData.ins.myPoint {
            pointP = "\(myPoint.stringValue.addComma()) P"
        }
        CNavigationBar.drawRight(self, nil, pointP, TAG_NAVI_P_COINT, nil)

        var pointS = "0 S"
        if let sPoint = ShareData.ins.dfsGet(DfsKey.userR) as? NSNumber {
            pointS = "\(sPoint.stringValue.addComma()) S"
        }
        CNavigationBar.drawRight(self, nil, pointS, TAG_NAVI_S_COINT, nil)
    }
    
    func updateUnReadMessageCount() {
        var findLabel:UILabel?
        for btn in btnTabs {
            if btn.tag == 4, let lbCount = btn.viewWithTag(103) as? UILabel {
                findLabel = lbCount
                break
            }
        }
        guard let lbCatMsgCnt = findLabel else {
            return
        }
        
        DBManager.ins.getAllUnReadMessageCount { (count) in
            if count > 0 {
                lbCatMsgCnt.isHidden = false
                lbCatMsgCnt.text = "\(count)"
            }
            else {
                lbCatMsgCnt.isHidden = true
            }
        }
    }
    
}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
