//
//  MainViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import UIKit
import SideMenu
import SwiftyJSON
class MainViewController: BaseViewController {
    @IBOutlet weak var naviView: UIView!
    @IBOutlet weak var heightNaviView: NSLayoutConstraint!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnPoint: UIButton!
    @IBOutlet weak var lbPoint: UILabel!
    @IBOutlet weak var lbPointS: UILabel!
    @IBOutlet weak var bannerBgView: UIView!
    @IBOutlet weak var ivBanner: UIImageView!
    @IBOutlet weak var notiView: UIView!
    @IBOutlet weak var lbNoti: UILabel!
    
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
    var bannerList = [JSON]()
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
            notiView.isHidden = true
            if selIndex == 0 {
                svItems.isHidden = false
                floatRocket.isHidden = false
                floatPlus.isHidden = false
                if ShareData.ins.mySex == .femail {
                    notiView.isHidden = false
                    lbNoti.text = NSLocalizedString("activity_txt114", comment: "")
                }
            }
            else if selIndex == 1 {
                svItems.isHidden = false
                floatRocket.isHidden = true
                floatPlus.isHidden = false
                if ShareData.ins.mySex == .femail {
                    notiView.isHidden = false
                    lbNoti.text = NSLocalizedString("activity_txt157", comment: "")
                }
            }
            else if selIndex == 2 {
                svItems.isHidden = false
                floatRocket.isHidden = true
                floatPlus.isHidden = false
                if ShareData.ins.mySex == .femail {
                    notiView.isHidden = false
                    lbNoti.text = NSLocalizedString("activity_txt149", comment: "")
                }
            }
            
            oldSelIndex = selIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        CNavigationBar.drawLeftBarItem(self, UIImage(systemName: "text.justify"), "activity_txt299".localized, TAG_NAVI_TITLE, #selector(onclickedBtnActions(_ :)))
//
//        CNavigationBar.drawRight(self, nil, "0 P", TAG_NAVI_P_COINT, nil)
//        CNavigationBar.drawRight(self, nil, "0 S", TAG_NAVI_S_COINT, nil)
//        CNavigationBar.drawRight(self, UIImage(named: "point"), nil, TAG_NAVI_POINT, #selector(onclickedBtnActions(_:)))
//
        naviView.addShadow(offset: CGSize(width: 1, height: 1), color: RGBA(0, 0, 0, 0.3), raduius: 3, opacity: 0.3)
        if Utility.isEdgePhone() == false {
            heightNaviView.constant = heightNaviView.constant - 34
        }
 
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
        btnRocket.layer.cornerRadius = btnRocket.bounds.height/2
        btnPlus.layer.cornerRadius = btnPlus.bounds.height/2
//        appDelegate.apptrakingPermissionCheck()
        AdbrixEvent.addEventLog(.login, ["user_id": ShareData.ins.myId, "user_name":ShareData.ins.myName, "user_sex":ShareData.ins.mySex.rawValue])
        
//        self.requestEventList()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_:)))
        ivBanner.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUnReadMessageCount()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        self.updateNaviPoint()
        self.requestMyInfo()
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
    }
    
    override func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.view == ivBanner {
            btnPoint.sendActions(for: .touchUpInside)
        }
    }
    
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
//        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (appDelegate.window?.rootViewController?.view)!)
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
    @IBAction func onclickedBtnActions(_ sender:UIButton) {
        if sender == btnMenu {
            guard let left = SideMenuManager.default.leftMenuNavigationController else { return }
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (self.navigationController?.view)!, forMenu: .right)
            self.present(left, animated: true, completion: nil)
        }
        else if sender == btnPoint {
            let vc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if btnTabs.contains(sender) == true {
            self.selIndex = sender.tag
        }
        else if sender == btnPlus {
            if selIndex == 0 {
                let vc = TalkWriteViewController.instant(withType: .cam)
                appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
            else if selIndex == 1 {
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
//        CNavigationBar.drawRight(self, nil, pointP, TAG_NAVI_P_COINT, nil)
        let attr = NSAttributedString.init(string: pointP, attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue])
        lbPoint.attributedText = attr
        
        var pointS = "0 S"
        if let sPoint = ShareData.ins.dfsGet(DfsKey.userR) as? NSNumber {
            pointS = "\(sPoint.stringValue.addComma()) S"
        }
        let attrs = NSAttributedString.init(string: pointS, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        lbPointS.attributedText = attrs
//        CNavigationBar.drawRight(self, nil, pointS, TAG_NAVI_S_COINT, nil)
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
