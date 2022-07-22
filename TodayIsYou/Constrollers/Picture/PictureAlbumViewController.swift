//
//  PictureAlbumViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/27.
//

import UIKit
import SwiftyJSON
import AppsFlyerLib

class PictureAlbumViewController: MainActionViewController {
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbPictureCnt: UILabel!
    @IBOutlet weak var lbJimCnt: UILabel!
    
    @IBOutlet weak var btnSendMsg: CButton!
    @IBOutlet weak var btnJim: CButton!
    @IBOutlet weak var btnEditProfile: CButton!
    @IBOutlet weak var btnRegistPictorial: CButton!
    
    @IBOutlet weak var linkView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    var viewModel: PictureAlbumViewModel!
    static func initWithModel(_ viewModel: PictureAlbumViewModel) ->PictureAlbumViewController {
        let vc = PictureAlbumViewController.instantiateFromStoryboard(.picture)!
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = String(format: NSLocalizedString("picture_detail_title2", comment: "..님의 앨범"), viewModel.bpUserName)
        CNavigationBar.drawBackButton(self, title, #selector(actionNaviBack))
        
        initUI()
        viewModel.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.dataRest()
    }
    private func initUI() {
        let layout = CFlowLayout.init()
        layout.numberOfColumns = 2
        layout.delegate = self
        layout.lineSpacing = 4
        layout.secInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        self.collectionView.collectionViewLayout = layout
        
        ivProfile.contentMode = .scaleAspectFill
        ivProfile.layer.cornerRadius = 4
        ivProfile.layer.borderColor = UIColor.appColor(.gray224).cgColor
        ivProfile.layer.borderWidth = 1
        ivProfile.clipsToBounds = true
        
        let moneyStr = "2,000"
        let tmpStr = String(format: NSLocalizedString("picture_recoment_point", comment: ""), moneyStr)
        let attr = NSMutableAttributedString.init(string: tmpStr)
        attr.addAttribute(.foregroundColor, value: UIColor.appColor(.appColor), range: (tmpStr as NSString).range(of: moneyStr))
        attr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, tmpStr.count))
        attr.addAttribute(.underlineColor, value: UIColor.appColor(.blackText), range: NSMakeRange(0, tmpStr.count))
        let lbRecomendLink = linkView.viewWithTag(100) as! UILabel
        lbRecomendLink.attributedText = attr
        
        linkView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_:))))
        
        btnJim.isHidden = viewModel.isMe
        btnSendMsg.isHidden = viewModel.isMe
        btnEditProfile.isHidden = !viewModel.isMe
        btnRegistPictorial.isHidden = !viewModel.isMe
    }
    
    private func configurationUI() {
        lbUserName.text = viewModel.data.user_name
        lbContent.text = viewModel.data.contents
        lbPictureCnt.text = "\(viewModel.data.cnt)".addComma()
        lbJimCnt.text = "\(viewModel.data.fw_cnt)".addComma()
        
        ivProfile.image = UIImage(systemName: "person.fill")
        ivProfile.tintColor = .appColor(.gray204)
        if viewModel.data.user_img.length > 0 {
            ivProfile.setImageCache(viewModel.data.user_img)
        }
        
        if viewModel.data.friend_cnt == "N" {
            btnJim.backgroundColor = .appColor(.gray204)
        }
        else {
            btnJim.backgroundColor = .appColor(.appColor)
        }
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
    
    private func showDocumnetVc(_ url: URL) {
        let snapshot = self.view.snapshot
        let message = NSLocalizedString("activity_txt599", comment: "") + "\n\(url)"
        let items = [snapshot, message] as [Any]
        let vc = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.view
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnJim {
            if viewModel.isMe {
                self.showToast(NSLocalizedString("activity_txt01", comment: "본인입니다."))
                return
            }
            
            if viewModel.data.friend_cnt == "N" {
                self.requestSetMyFriend()
            }
            else {
                self.requestDeleteMyFriend(NSNumber(value: viewModel.data.zzim_seq))
            }
        }
        else if sender == btnSendMsg {
            self.selUser = JSON(["user_id" : self.viewModel.bpUserId])
            self.checkTalk()
        }
        else if sender == btnEditProfile {
//            guard let seq = self.viewModel.listData.first?.seq else { return }
//            weak var weakSelf = self
//            let vc = PictureWkWebViewController.instantiateFromStoryboard(.picture)!
//            vc.param = ["user_id" : ShareData.ins.myId, "mode": "modify", "seq": seq]
//            vc.vcTitle = NSLocalizedString("picture_modify_title", comment: "화보 수정")
//            self.navigationController?.pushViewController(vc, animated: true)
//            vc.didFinish = {(reuslt) ->Void in
//                guard let self = weakSelf else { return }
//                self.viewModel.dataRest()
//            }
            let vc = ProfileManagerViewController.instantiateFromStoryboard(.main)!
            appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
        }
        else if sender == btnRegistPictorial {
            let vc = PictureWkWebViewController.instantiateFromStoryboard(.picture)!
            vc.param = ["user_id" : ShareData.ins.myId]
            vc.vcTitle = NSLocalizedString("picture_regist_title", comment: "화보등록")
            weak var weakSelf = self
            vc.didFinish = {(reuslt) ->Void in
                guard let self = weakSelf else { return }
                self.viewModel.dataRest()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //찜등록
    private func requestSetMyFriend() {
        let param:[String:Any] = ["my_id":ShareData.ins.myId, "user_id": viewModel.bpUserId!, "user_name":viewModel.data.user_name]
        
        ApiManager.ins.requestSetMyFried(param: param) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.showToast(NSLocalizedString("activity_txt243", comment: "찜등록완료!!"))
                self.viewModel.dataRest()
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
                self.viewModel.dataRest()
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { (error) in
            self.showErrorToast(error)
        }
    }
}

extension PictureAlbumViewController: PictureAlbemViewModelDelegate {
    func reloadData() {
        self.configurationUI()
        self.collectionView.reloadData {
            self.collectionView.reloadData()
        }
    }
    func showErrPopup(error: CError?) {
        self.showErrorToast(error)
    }
}

extension PictureAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureAlbumColCell", for: indexPath) as? PictureAlbumColCell else {
            return UICollectionViewCell()
        }
        
        let model = viewModel.listData[indexPath.row]
//        print(model.pb_url)
        cell.configurationData(model: model)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        var model = viewModel.listData[indexpath.row]
        if model.height > 0 {
//            print("=== aleardy height")
            return model.height
        }
        else {
            let index = (indexpath.row % randomRowRates.count)
            let rate = randomRowRates[index]
            let heigith = 300 * rate
            model.height = heigith
            viewModel.listData[indexpath.row] = model

//            print("=== new height")
            return heigith
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = viewModel.listData[indexPath.row]
        let detailViewModel = PictureDetailViewModel(seq: model.seq, bpUserId: model.user_id)
        let vc = PictureDetailViewController.initWithViewModel(detailViewModel)
        appDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
    }
}

extension PictureAlbumViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let offsetY = floor((scrollView.contentOffset.y + scrollView.bounds.height)*100)/100
        let contentH = floor(scrollView.contentSize.height*100)/100
        
        if velocityY < 0 && offsetY > contentH && viewModel.canRequest == true {
            viewModel.canRequest = false
            viewModel.addData()
        }
    }

}
