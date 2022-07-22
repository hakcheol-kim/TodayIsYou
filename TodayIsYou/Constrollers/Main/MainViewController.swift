//
//  MainViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SideMenu
import SwiftyJSON
import AdSupport
import AppTrackingTransparency
import AlamofireImage

enum MainTab: Int {
    case video, talk, picture, rank, chat, setting
    
    var title: String {
        switch self {
        case .video:
            return NSLocalizedString("activity_txt561", comment: "영상")
        case .talk:
            return NSLocalizedString("activity_txt562", comment: "토크")
        case .picture:
            return NSLocalizedString("picture_show_title1", comment: "룩북")
        case .rank:
            return NSLocalizedString("activity_txt564", comment: "랭킹")
        case .chat:
            return NSLocalizedString("activity_txt565", comment: "쪽지함")
        case .setting:
            return NSLocalizedString("activity_txt566", comment: "설정")
        }
    }
    var selectedImage: UIImage {
        switch self {
        case .video:
            return UIImage(named: "cam_call_over") ?? UIImage()
        case .talk:
            return UIImage(named: "talk_over") ?? UIImage()
        case .picture:
            return UIImage(named: "photo_over") ?? UIImage()
        case .rank:
            return UIImage(named: "rank_over") ?? UIImage()
        case .chat:
            return UIImage(named: "message_over") ?? UIImage()
        case .setting:
            return UIImage(named: "setting_over") ?? UIImage()
        }
    }
    var normalImage: UIImage {
        switch self {
        case .video:
            return UIImage(named: "cam_call") ?? UIImage()
        case .talk:
            return UIImage(named: "talk") ?? UIImage()
        case .picture:
            return UIImage(named: "photo") ?? UIImage()
        case .rank:
            return UIImage(named: "rank") ?? UIImage()
        case .chat:
            return UIImage(named: "message") ?? UIImage()
        case .setting:
            return UIImage(named: "setting") ?? UIImage()
        }
    }
}

class MainViewController: MainActionViewController {
    @IBOutlet weak var naviView: UIView!
    @IBOutlet weak var heightNaviView: NSLayoutConstraint!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnPoint: UIButton!
    @IBOutlet weak var lbPoint: UILabel!
    @IBOutlet weak var lbPointS: UILabel!
    @IBOutlet weak var underLineView: UIView!
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var svTab: UIStackView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var floatRandomChat: CView!
    @IBOutlet weak var floatRocket: CView!
    @IBOutlet weak var floatPlus: CView!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnRocket: UIButton!
    @IBOutlet weak var btnRandomChat: UIButton!
    @IBOutlet weak var svItems: UIStackView!
    
    
    var selectedVc: UIViewController?
    
    var videoSortType: SortedType = SortedType.getSortType(ShareData.ins.mySex.transGender())
    var videoListType: ListType = .image
    var bannerList = [JSON]()
    var arrTabs: [MainTab]!
    var mainTabs = [MainTabButton]()
    
    private var curTabMenu: MainTab!
    private var oldTabMenu: MainTab!
    
    private var scrollDirection = ScrollDirection.none
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.mainCtl = self 
        
        if ShareData.ins.isReview {
            arrTabs = [.video, .talk, .rank, .chat, .setting]
            videoListType = .text
        }
        else {
            arrTabs = [.video, .talk, .picture, .rank, .chat, .setting]
            videoListType = .image
        }
        
        naviView.addShadow(offset: CGSize(width: 1, height: 1), color: RGBA(0, 0, 0, 0.3), raduius: 3, opacity: 0.3)
        if Utility.isEdgePhone() == false {
            heightNaviView.constant = heightNaviView.constant - 34
        }

        svTab.subviews.forEach({ subview in
            subview.removeFromSuperview()
        })
        
        for tab in arrTabs {
            let btnTab = MainTabButton()
            svTab.addArrangedSubview(btnTab)
            btnTab.lbTitle.text = tab.title
            btnTab.ivIcon.image = tab.normalImage
            btnTab.ivIcon.isHidden = true
            btnTab.isSelected = false
            btnTab.tabId = tab
            mainTabs.append(btnTab)
            btnTab.addTarget(self, action: #selector(onclickedBtnActions(_:)), for: .touchUpInside)
        }
        
        self.curTabMenu = .video
        self.changeTabMenu()
        
        floatPlus.layer.cornerRadius = floatPlus.bounds.height/2
        floatRocket.layer.cornerRadius = floatRocket.bounds.height/2
        floatRandomChat.layer.cornerRadius = floatRandomChat.bounds.height/2
        btnPlus.layer.cornerRadius = btnPlus.bounds.height/2
        btnRocket.layer.cornerRadius = btnRocket.bounds.height/2
        btnRandomChat.layer.cornerRadius = btnRandomChat.bounds.height/2
        
        
        setupSideMenu()
        updateMenus()
        self.requestMyHomePoint()
        btnRocket.layer.cornerRadius = btnRocket.bounds.height/2
        btnPlus.layer.cornerRadius = btnPlus.bounds.height/2
//        appDelegate.apptrakingPermissionCheck()
        AppsFlyerEvent.addEventLog(.login, ["user_id": ShareData.ins.myId, "user_name":ShareData.ins.myName, "user_sex":ShareData.ins.mySex.rawValue])
        appDelegate.registApnsPushKey()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUnReadMessageCount()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.requestMyInfo()
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
    }
    
    
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (appDelegate.window?.rootViewController?.view)!)
    }
    private func addChildView(_ tab: MainTab) {
        switch tab {
        case .video:
            let vc = CamTalkListViewController.instantiateFromStoryboard(.main)!
            vc.sortType = videoSortType
            vc.listType = videoListType
            vc.didScroll = {(direction, offsetY) ->(Void) in
                if self.scrollDirection != direction {
                    self.floatItemAnimation()
                }
                self.scrollDirection = direction
            }
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            self.selectedVc = vc
//            self.changeNaviTitle("activity_txt561".localized)
        
            break
        case .talk:
            let vc = TalkListViewController.instantiateFromStoryboard(.main)!
            vc.didScroll = {(direction, offsetY) ->(Void) in
                if self.scrollDirection != direction {
                    self.floatItemAnimation()
                }
                self.scrollDirection = direction
            }
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            self.selectedVc = vc
//            self.changeNaviTitle("activity_txt562".localized)
            break
        case .picture:
//            let vc = PhotoListViewController.instantiateFromStoryboard(.main)!
//            self.myAddChildViewController(superView: containerView, childViewController: vc)
//            self.selectedVc = vc
//            self.changeNaviTitle("activity_txt563".localized)
//            break
            let vc = PictureContainerViewController.instantiateFromStoryboard(.picture)!
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            vc.didScroll = {(direction, offsetY) ->(Void) in
                if self.scrollDirection != direction {
                    self.floatItemAnimation()
                }
                self.scrollDirection = direction
            }
            self.selectedVc = vc
            break
        case .rank:
            let vc = RankListViewController.instantiateFromStoryboard(.main)!
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            self.selectedVc = vc
//            self.changeNaviTitle("activity_txt563".localized)
            break
        case .chat:
            let vc = ChattingListViewController.instantiateFromStoryboard(.main)!
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            self.selectedVc = vc
//            self.changeNaviTitle("activity_txt566".localized)
            break
        case .setting:
            let vc = SettingViewController.instantiateFromStoryboard(.main)!
            self.myAddChildViewController(superView: containerView, childViewController: vc)
            self.selectedVc = vc
//            self.changeNaviTitle("activity_txt566".localized)
            break
        }
    }
    @objc func floatItemAnimation() {
        print("\(scrollDirection)")
        
        if scrollDirection == .up {
            self.svItems.alpha = 0
            self.svItems.spacing = -56
            self.svItems.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {
                self.svItems.spacing = 10
                self.svItems.alpha = 1
            } completion: { finish in
                self.svItems.isHidden = false
            }
        }
        else {
            self.svItems.alpha = 1
            self.svItems.spacing = 10
            self.svItems.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {
                self.svItems.spacing = -56
                self.svItems.alpha = 0
            } completion: { finish in
                self.svItems.isHidden = true
            }
        }
        
    }
    func changeTabMenu() {
        if oldTabMenu != nil || oldTabMenu != curTabMenu {
            if let selectedVc = selectedVc {
                self.myRemoveChildViewController(childViewController: selectedVc)
            }
            self.addChildView(curTabMenu)
            
            svItems.isHidden = true
            for btn in mainTabs {
                if btn.tabId == curTabMenu {
                    btn.isSelected = true
                }
                else {
                    btn.isSelected = false
                }
                if curTabMenu == .video {
                    svItems.isHidden = false
                    floatRocket.isHidden = false
                    floatPlus.isHidden = false
                    floatRandomChat.isHidden = (ShareData.ins.mySex != .femail)
                }
                else if curTabMenu == .talk {
                    svItems.isHidden = false
                    floatRocket.isHidden = true
                    floatPlus.isHidden = false
                    floatRandomChat.isHidden = (ShareData.ins.mySex != .femail)
                }
                else if curTabMenu == .picture {
                    svItems.isHidden = false
                    floatRocket.isHidden = true
                    floatPlus.isHidden = false
                }
                            
            }
            self.oldTabMenu = curTabMenu
        }
    }
    func requestEventList() {
        let dateStr = Date().stringDateWithFormat("yyyyMMdd")
        let saveDate = ShareData.ins.dfsGet(DfsKey.eventBanerSeeDate) as? String ?? ""
        if dateStr == saveDate {
            return
        }
        
        ApiManager.ins.requestEventList { res in
            let code = res["code"].stringValue
            let banner_list = res["banner_list"].arrayValue
            if code == "000", banner_list.count > 0 {
                self.bannerList = banner_list
                self.showEventBannerListView()
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func showEventBannerListView() {
        let vc = BannerListViewController.instantiateFromStoryboard(.other)!
        vc.data = bannerList
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    @IBAction func onclickedBtnActions(_ sender: UIButton) {
        if sender == btnMenu {
            guard let left = SideMenuManager.default.leftMenuNavigationController else { return }
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view, forMenu: .right)
            self.present(left, animated: true, completion: nil)
        }
        else if sender == btnPoint {
            let vc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if let btn = sender as? MainTabButton, mainTabs.contains(btn) {
            self.curTabMenu = btn.tabId
            self.changeTabMenu()
        }
        else if sender == btnPlus {
            if curTabMenu == .video {
                let vc = TalkWriteViewController.instant(withType: .cam)
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
            else if curTabMenu == .talk {
                let vc = TalkWriteViewController.instant(withType: .talk)
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
            else {
                let vc = PhotoTalkWriteViewController.instantiateFromStoryboard(.main)!
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
        }
        else if sender == btnRocket {

            CAlertViewController.show(type: .alert, title: NSLocalizedString("activity_txt118", comment: "빠른 영상채팅 신청"), message: NSLocalizedString("activity_txt122", comment: "빠른 영상채팅 신청을 합니다."), actions: [.cancel, .ok]) { vcs, selItem, action in
                vcs.dismiss(animated: true, completion: nil)
                if action == 1 {
                    let vc = RandomCallViewController.instantiateFromStoryboard(.call)!
                    appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
//                    vc.modalPresentationStyle = .fullScreen
//                    appDelegate.window?.rootViewController?.present(vc, animated: true)
                }
            }
        }
        else if sender == btnRandomChat {
            let contentView = RandomMsgAlertView()
            weak var weakSelf = self
            let vc = CAlertViewController.init(type: .custom, title: NSLocalizedString("random_msg_title", comment: "램덤 쪽지발생"), message: nil, actions: nil) { vcs, selItem, index in
                guard let self = weakSelf else { return }
                
                if index == 1 {
                    guard let text = contentView.tvContent.text, !text.isEmpty else { return }
                    print(text)
                    var param = [String:Any]()
                    param["from_user_id"] = ShareData.ins.myId
                    param["from_user_name"] = ShareData.ins.myName
                    param["to_user_gender"] = ShareData.ins.mySex.transGender().rawValue
                    param["memo"] = text
                    
                    self.sendRandomMessage(param)
                    vcs.dismiss(animated: true, completion: nil)
                }
                else {
                    vcs.dismiss(animated: true, completion: nil)
                }
            }
            vc.addCustomView(contentView)
            vc.addAction(.cancel, NSLocalizedString("activity_txt479", comment: "취소"))
            vc.addAction(.ok, NSLocalizedString("layout_txt130", comment: "전송"))
            appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
            
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
        if let path = Bundle.main.path(forResource: "img_back2", ofType: "jpg"), let img = UIImage(contentsOfFile: path) {
            presentationStyle.backgroundColor = UIColor.init(patternImage: img)
        }
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

        let attr = NSAttributedString.init(string: pointP, attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue])
        lbPoint.attributedText = attr
        
        var pointS = "0 S"
        if let sPoint = ShareData.ins.dfsGet(DfsKey.userR) as? NSNumber {
            pointS = "\(sPoint.stringValue.addComma()) S"
        }
        let attrs = NSAttributedString.init(string: pointS, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        lbPointS.attributedText = attrs
    }
    
    func updateUnReadMessageCount() {
        guard let btnChat = mainTabs.filter { tab in return tab.tabId == .chat }.first else {
            return
        }

        DBManager.ins.getAllUnReadMessageCount { (count) in
            if count > 0 {
                btnChat.btnCnt.isHidden = false
                btnChat.btnCnt.setTitle("\(count)", for: .normal)
                btnChat.btnCnt.layer.cornerRadius = btnChat.btnCnt.bounds.size.height/2
            }
            else {
                btnChat.btnCnt.isHidden = true
            }
        }
    }
    
}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
