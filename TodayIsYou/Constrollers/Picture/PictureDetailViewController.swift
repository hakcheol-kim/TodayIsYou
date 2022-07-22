//
//  PictureDetailViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/26.
//

import UIKit
import Lightbox
import SideMenu
import AVKit
import SocketIO
import SwiftyJSON
import AppsFlyerLib

class PictureDetailViewController: MainActionViewController {
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var btnJim: CButton!
    @IBOutlet weak var lbDescription: UILabel!
    
    @IBOutlet weak var svModify: UIStackView!
    @IBOutlet weak var btnAlbem: CButton!
    @IBOutlet weak var btnSendMsg: CButton!
    @IBOutlet weak var btnModify: CButton!
    @IBOutlet weak var btnDelete: CButton!
    @IBOutlet weak var linkView: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var btnPlayer: CButton!
    @IBOutlet var btnState: CButton!
    @IBOutlet var lbPoint: UILabel!
    @IBOutlet var lb19Pluse: Clabel!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var btnPurchase: CButton!
    
    
    var itemSize: CGSize = .zero
    var didModify: (() ->Void)?
    var viewModel: PictureDetailViewModel!
    
    let playerViewController = AVPlayerViewController()
    var plyaer = AVPlayer()
    static func initWithViewModel(_ viewmodel:PictureDetailViewModel) -> PictureDetailViewController {
        let vc = PictureDetailViewController.instantiateFromStoryboard(.picture)!
        vc.viewModel = viewmodel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.delegate = self
        CNavigationBar.drawBackButton(self, NSLocalizedString("picture_detail_title", comment: "화보보기"), #selector(actionNaviBack))
        
        self.initUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.requestPictureDetail()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.viewModel.isModify {
            didModify?()
        }
    }
    private func initUI() {
        pagerView.register(UINib(nibName: "PictureDetailColCell", bundle: nil), forCellWithReuseIdentifier: "PictureDetailColCell")
        pagerView.automaticSlidingInterval = 3.0
        pagerView.isInfinite = false
        pagerView.decelerationDistance = FSPagerView.automaticDistance
        
        pagerView.interitemSpacing = 0
        let scale = CGFloat(1)
        self.itemSize = pagerView.frame.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        pagerView.itemSize = itemSize
        
        pagerView.delegate = self
        pagerView.dataSource = self
        
        let moneyStr = "2,000"
        let tmpStr = String(format: NSLocalizedString("picture_recoment_point", comment: ""), moneyStr)
        let attr = NSMutableAttributedString.init(string: tmpStr)
        attr.addAttribute(.foregroundColor, value: UIColor.appColor(.appColor), range: (tmpStr as NSString).range(of: moneyStr))
        attr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, tmpStr.count))
        attr.addAttribute(.underlineColor, value: UIColor.appColor(.blackText), range: NSMakeRange(0, tmpStr.count))
        let lbRecomendLink = linkView.viewWithTag(100) as! UILabel
        lbRecomendLink.attributedText = attr
        
        linkView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_:))))
        btnSendMsg.isHidden = viewModel.isMe
    }
    
    private func clearUI() {
        lbNickName.text = ""
        lbDescription.text = ""
        svModify.isHidden = true
        lbPoint.text = ""
        btnPlayer.isHidden = true
        btnPurchase.isHidden = true
    }
    private func configurationData() {
        guard let model = self.viewModel.data else {
            self.clearUI()
            return
        }
        debugPrint("====== \(model.pb_url_arr)")
        
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        ivProfile.layer.borderColor = UIColor.appColor(.gray221).cgColor
        ivProfile.layer.borderWidth = 0.5
        ivProfile.clipsToBounds = true
        
        if model.user_img.length > 0 {
            ivProfile.setImageCache(model.user_img, nil)
        }
        
        lbNickName.text = model.user_name + "," + model.user_age
        lbDescription.text = model.bp_subject
        
        svModify.isHidden = (model.edit_yn == "N")
        if model.friend_cnt == "N" {
            btnJim.backgroundColor = .appColor(.gray204)
            btnJim.tintColor = .appColor(.whiteText)
        }
        else {
            btnJim.backgroundColor = .appColor(.naviLight)
            btnJim.tintColor = .appColor(.yellow)
        }
        
        
        let effect = UIBlurEffect.init(style: .extraLight)
        visualEffectView.effect = effect
        visualEffectView.alpha = 0.85
        btnPlayer.imageView?.contentMode = .scaleToFill;

        
        visualEffectView.isHidden = true
        btnPlayer.isHidden = true
        btnPurchase.isHidden = true
        
        lb19Pluse.isHidden = (model.bp_adult != "Y")
        
        //유료이고, 구매 안한거면 불러 및 구매하기 버튼 노출
        if model.purchase_status == "N" && model.bp_point > 0 && viewModel.isMe == false {
            visualEffectView.isHidden = false
            btnPurchase.isHidden = false
        }

        if model.bp_point > 0 {
            btnState.setTitle(NSLocalizedString("picture_not_charge", comment: "유료"), for: .normal)
            btnState.backgroundColor = .appColor(.appColor)
        }
        else {
            btnState.setTitle(NSLocalizedString("picture_free", comment: "무료"), for: .normal)
            btnState.backgroundColor = .appColor(.blueLight)
        }
       
        btnPlayer.isHidden = (model.bp_type != "V")
        lbPoint.text = "\(model.bp_point)".addComma() + "P"
        
        pageControl.numberOfPages = model.pb_url_arr.count
        if model.pb_url_arr.count > 1 {
            pageControl.isHidden = false
        }
        else {
            pageControl.isHidden = true
        }
        pagerView.reloadData()
    }
    
    private func showDocumnetVc(_ url: URL) {
        let snapshot = pagerView.snapshot
        let message = NSLocalizedString("activity_txt599", comment: "") + "\n\(url)"
        let items = [snapshot, message] as [Any]
        let vc = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.view
        self.present(vc, animated: true, completion: nil)
    }
    //Share tapgesturehandler
    @objc override func tapGestureHandler(_ gestrue: UITapGestureRecognizer) {
        if gestrue.view == linkView {
            print("did tap")
            AppsFlyerShareInviteHelper.generateInviteUrl { generator in
                generator.setBaseDeeplink("http://todayisyou.co.kr")
                generator.setDeeplinkPath("/homepage/sns/today_model.php")
                generator.addParameterValue(ShareData.ins.myId, forKey: "ukey")
                generator.addParameterValue(self.viewModel.bpUserId, forKey: "skey")
                generator.setCampaign("share_picture")
                generator.setAppleAppID(APPLE_APP_ID)
                
                return generator
            } completionHandler: { url in
                guard let url = url else {
                    print("empty inviteurl")
                    return
                }
                let urlStr = "\(url.absoluteString)?af_force_deeplink=true"
                guard let forceRedirectUrl = URL(string: urlStr) else { return }
                print("==== adflyer invite url: \(forceRedirectUrl)")
                DispatchQueue.main.async {
                    self.showDocumnetVc(forceRedirectUrl)
                }
            }
        }
    }
    
    //MARK: - 버튼 액션
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
        if sender == btnAlbem {
            guard let model = self.viewModel.data else { return }
            let viewModel = PictureAlbumViewModel(bpUserId: viewModel.bpUserId, bpUserName: model.user_name)
            let vc = PictureAlbumViewController.initWithModel(viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnJim {
            guard let model = self.viewModel.data else { return }
            if viewModel.isMe {
                self.showToast(NSLocalizedString("activity_txt01", comment: "본인입니다."))
                return
            }
            
            if model.friend_cnt == "N" {
                self.requestSetMyFriend()
            }
            else {
                self.requestDeleteMyFriend(NSNumber(value: model.zzim_seq))
            }
        }
        else if sender == btnSendMsg {
            self.selUser = JSON(["user_id" : self.viewModel.bpUserId])
            self.checkTalk()
        }
        else if sender == btnDelete {
            CAlertView.showWithCanCelOk(title: nil, message: NSLocalizedString("picture_point_message4", comment: "")) { action in
                if action == 1 {
                    self.viewModel.requestDeletePicture()
                }
            }
        }
        else if sender == btnModify {
            guard let seq = viewModel.seq else { return }
            
            let vc = PictureWkWebViewController.instantiateFromStoryboard(.picture)!
            vc.param = ["user_id" : ShareData.ins.myId, "mode": "modify", "seq": seq]
            vc.vcTitle = NSLocalizedString("picture_modify_title", comment: "화보 수정")
            self.navigationController?.pushViewController(vc, animated: true)
            vc.didFinish = {(reuslt) ->Void in
                self.viewModel.requestPictureDetail()
            }
        }
        else if sender == btnPurchase {
            guard let model = self.viewModel.data else { return }
            self.showAlertPurchages(model)
        }
        else if sender == btnPlayer {
            guard let model = self.viewModel.data else { return }
            
            if model.purchase_status == "N" && model.bp_point > 0 && self.viewModel.isMe == false {
                self.showAlertPurchages(model)
            }
            else {
                guard let videoUrl = URL(string: model.bp_vod_url) else {
                    return
                }
                self.plyaer = AVPlayer(url: videoUrl)
                self.playerViewController.player = self.plyaer

                self.present(self.playerViewController, animated: true) {
                    self.playerViewController.player?.play()
                }
            }
        }
    }
    //찜등록
    private func requestSetMyFriend() {
        guard let model = self.viewModel.data else { return }
        let param:[String:Any] = ["my_id":ShareData.ins.myId, "user_id": viewModel.bpUserId!, "user_name":model.user_name]
        
        ApiManager.ins.requestSetMyFried(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.showToast(NSLocalizedString("activity_txt243", comment: "찜등록완료!!"))
                self.viewModel.requestPictureDetail()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (err) in
            self.showErrorToast(err)
        }
    }
    //찜삭제
    func requestDeleteMyFriend(_ seq:NSNumber) {
        let param = ["seq":seq]
        ApiManager.ins.requestDeleteMyFriend(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.viewModel.requestPictureDetail()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }
    }
    private func showAlertPurchages(_ detailModel:PictureDetail) {
        let myPoint = ShareData.ins.myPoint?.intValue ?? 0
        if detailModel.bp_point > myPoint { //포인트 부족
            CAlertView.showWithCustomButton(title: nil, message: NSLocalizedString("picture_point_message2", comment: "포인트가 부족합니다..."), btnTitles: [NSLocalizedString("activity_txt201", comment: "취소"), NSLocalizedString("point_charge_alert_btn", comment: "충전하기")], btnTypes: [.cancel, .ok]) { index in
                if index == 1 {
                    let vc = PointPurchaseViewController.instantiateFromStoryboard(.main)!
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return
        }
        
        //구매 팝업
        let ponit = "\(detailModel.bp_point)".addComma()
        let msg = String(format: NSLocalizedString("picture_point_message1", comment: "화보구매시 %@포인트 차감됩니다."), ponit)
        CAlertView.showWithCustomButton(title: nil, message: msg, btnTitles: [NSLocalizedString("activity_txt201", comment: "취소"), NSLocalizedString("picture_btn_purchage", comment: "구매하기")], btnTypes: [.cancel, .ok]) { [weak self] index in
            guard let self = self else { return }
            if index == 1 {
                self.viewModel.requestPurchargePicture()
            }
        }
        return
    }
}
//MARK: - response call back
extension PictureDetailViewController: PictureDetailViewModelDelegate {
    func resDetail() {
        self.configurationData()
    }
    func showError(_ error: CError?) {
        self.showToast(error?.errorDescription)
        self.clearUI()
    }
    func resPurchasedPicture() {
        CAlertView.showWithOk(title: nil, message: NSLocalizedString("picture_point_message3", comment: "")) { action in
            self.viewModel.requestPictureDetail()
        }
    }
    func resDeletePickture() {
        appDelegate.window?.makeToast(NSLocalizedString("picture_point_message5", comment: "삭제가 완료되었습니다."))
        self.navigationController?.popViewController(animated: true)
    }
}

extension PictureDetailViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        guard let data = viewModel.data else {
            return 0
        }
        return data.pb_url_arr.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "PictureDetailColCell", at: index) as? PictureDetailColCell else {
            return UICollectionViewCell()
        }
        let url = viewModel.data.pb_url_arr[index]
        cell.ivThumb.setImageCache(url, nil)
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        self.showPhoto(imgUrls: self.viewModel.data.pb_url_arr)
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: UICollectionViewCell, forItemAt index: Int) {
        self.pageControl.currentPage = index
    }
}
