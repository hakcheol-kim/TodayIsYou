//
//  TalkWriteViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/02.
//

import UIKit
import SwiftyJSON
import PanModal

class TalkWriteViewController: BaseViewController {
    @IBOutlet var btnTalk: UIButton!
    @IBOutlet var btnRegiTalk: UIButton!
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var lbMsg:UILabel!
    @IBOutlet weak var btnLink: UIButton!
    
    var type: PhotoManageType = .cam
    var data:JSON!
    var selMemo: String = "" {
        didSet {
            if let lbTalk = btnTalk.viewWithTag(100) as? UILabel {
                lbTalk.text = selMemo
            }
        }
    }
    
    internal static func instant(withType type:PhotoManageType) ->TalkWriteViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TalkWriteViewController") as! TalkWriteViewController
        vc.type = type
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .cam {
            CNavigationBar.drawBackButton(self, "영상토크 등록", #selector(actionNaviBack))
            requestMyImgTalk()
            btnRegiTalk.setTitle("영상 토크 등록", for: .normal)
        }
        else {
            CNavigationBar.drawBackButton(self, "토크 등록", #selector(actionNaviBack))
            requestMyTalk()
            btnRegiTalk.setTitle("토크 등록", for: .normal)
        }
    }
    //영상토크
    func requestMyImgTalk() {
        ApiManager.ins.requestMyImgTalk(param: ["user_id":ShareData.ins.myId]) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.data = res
                self.decorationUi()
            }
            else {
                self.showErrorToast(res)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
    //토크
    func requestMyTalk() {
        ApiManager.ins.requestMyTalk(param: ["user_id":ShareData.ins.myId]) { (res) in
            let isSuccess = res["isSuccess"].stringValue
            if isSuccess == "01" {
                self.data = res
                self.decorationUi()
            }
            else {
                self.showErrorToast(res)
            }
        } failure: { (error) in
            self.showErrorToast(error)
        }
    }
   
    func decorationUi() {
        let contents = data["contents"].stringValue
        let user_img = data["user_img"].stringValue
        
        self.selMemo = contents
        let ivProfile = btnProfile.viewWithTag(100) as! UIImageView

        if let url = Utility.thumbnailUrl(ShareData.ins.myId, user_img) {
            ivProfile.setImageCache(url)
            ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
            ivProfile.clipsToBounds = true
        }
        else {
            ivProfile.image = Gender.defaultImg(ShareData.ins.mySex.rawValue)
        }
        
        lbMsg.text = "사진은 검증된 이미지만 등록 됩니다."
        if type == .cam {
            if let camDayPoint = ShareData.ins.dfsGet(DfsKey.camDayPoint) as? NSNumber, camDayPoint.intValue > 0, "남" == ShareData.ins.mySex.rawValue {
                lbMsg.text = "사진은 검증된 이미지만 등록 됩니다.\n1일 1회 토크 등록시 " + camDayPoint.stringValue + "P를 적립해 드립니다"
            }
        }
        else if type == .cam {
            if let talkDayPoint = ShareData.ins.dfsGet(DfsKey.talkDayPoint) as? NSNumber, talkDayPoint.intValue > 0, "남" == ShareData.ins.mySex.rawValue {
                lbMsg.text = "사진은 검증된 이미지만 등록 됩니다.\n1일 1회 토크 등록시 " + talkDayPoint.stringValue + "P를 적립해 드립니다"
            }
        }
        btnLink.isHidden = true
        if type == .cam {
            btnLink.isHidden = false
            let attr = NSAttributedString.init(string: "영상 채팅으로 적립 받고 환급받는 방법을 알아보기", attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
            btnLink.setAttributedTitle(attr, for: .normal)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnTalk {
            
            var list:[String] = []
            if type == .cam {
                guard let camTalkMemo = ShareData.ins.getCamTalkMemo() else {
                    return
                }
                list = camTalkMemo
            }
            else if type == .talk {
                guard let talkMemo = ShareData.ins.getTalkMemo() else {
                    return
                }
                list = talkMemo
            }
            if list.isEmpty == true { return }
            let vc = PopupListViewController.initWithType(.normal, "선택해주세요.", list, nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? String else {
                    return
                }
                self.selMemo = selItem
            }
            self.presentPanModal(vc)
        }
        else if sender == btnProfile {
            let vc = PhotoManagerViewController.instantiate(with: type)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnLink {
            ApiManager.ins.requestServiceTerms(mode: "yk6") { (res) in
                let isSuccess = res["isSuccess"].stringValue
                let yk = res["yk"].stringValue
                if isSuccess == "01", yk.isEmpty == false {
                    let vc = TermsViewController.init()
                    vc.vcTitle = "포인트 적립 방법 안내"
                    vc.content = yk
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.showErrorToast(res)
                }
            } failure: { (error) in
                self.showErrorToast(error)
            }
        }
        else if sender == btnRegiTalk {
            if type == .cam {
                let param = ["user_id":ShareData.ins.myId, "contents":selMemo]
                ApiManager.ins.requestChangeCamTalk(param: param) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    let point_save = res["point_save"].stringValue
                    if isSuccess == "01" {
                        if "Y1" == point_save && "남" == ShareData.ins.mySex.rawValue {
                            self.showToastWindow("포인트가 적립 되었습니다")
                        }
                        else if "Y2" == point_save && "남" == ShareData.ins.mySex.rawValue {
                            var point = "0"
                            if let p = ShareData.ins.dfsGet(DfsKey.dayLimitPoint) as? NSNumber {
                                point = p.stringValue
                            }
                            self.showToastWindow("보유한 포인트가 \(point.addComma()) 이하일때 적립 가능합니다.")
                        }
                        else {
                            self.showToastWindow("등록 완료되었습니다.")
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } fail: { (error) in
                    self.showErrorToast(error)
                }
            }
            else if type == .talk {
                let point = data["user_bbs_point"].numberValue
                let parma:[String:Any] = ["user_id" : ShareData.ins.myId, "title" : selMemo, "user_bbs_point" : point]
                ApiManager.ins.requestChangeTalk(param: parma) { (res) in
                    let isSuccess = res["isSuccess"].stringValue
                    let point_save = res["point_save"].stringValue
                    if isSuccess == "01" {
                        if "Y1" == point_save && "남" == ShareData.ins.mySex.rawValue {
                            self.showToastWindow("포인트가 적립 되었습니다")
                        }
                        else if "Y2" == point_save && "남" == ShareData.ins.mySex.rawValue {
                            var point = "0"
                            if let p = ShareData.ins.dfsGet(DfsKey.dayLimitPoint) as? NSNumber {
                                point = p.stringValue
                            }
                            self.showToastWindow("\(point.addComma()) 포인트 이하일때 적립 가능합니다(금일은 적립 불가능 합니다.)")
                        }
//                        else if "N" == point_save {
//                            self.showToastWindow("1일 1회 적립되었습니다.")
//                        }
//                        else if "W" == point_save {
//                            self.showToastWindow("1일 1회 적립되었습니다.")
//                        }
                        else {
                            self.showToastWindow("등록 완료!")
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        self.showErrorToast(res)
                    }
                } fail: { (err) in
                    self.showErrorToast(err)
                }
            }
        }
    }
}
