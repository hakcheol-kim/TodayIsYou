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
    @IBOutlet weak var tfMemo: CTextField!
    
    var type: PhotoManageType = .cam
    var data:JSON!
    var selMemo: String = ""
    
    internal static func instant(withType type:PhotoManageType) ->TalkWriteViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TalkWriteViewController") as! TalkWriteViewController
        vc.type = type
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .cam {
            CNavigationBar.drawBackButton(self, NSLocalizedString("layout_txt15", comment: "영상토크 등록"), #selector(actionNaviBack))
            btnRegiTalk.setTitle(NSLocalizedString("layout_txt15", comment: "영상토크 등록"), for: .normal)
        }
        else {
            CNavigationBar.drawBackButton(self, NSLocalizedString("layout_txt145", comment: "토크 등록"), #selector(actionNaviBack))
            btnRegiTalk.setTitle(NSLocalizedString("layout_txt145", comment: "토크 등록"), for: .normal)
        }
        btnLink.titleLabel?.numberOfLines = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if type == .cam {
            requestMyImgTalk()
        }
        else {
            requestMyTalk()
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
        
        lbMsg.text = NSLocalizedString("activity_txt520", comment: "사진은 검증된 이미지만 등록 됩니다.")
        if type == .cam {
            if let camDayPoint = ShareData.ins.dfsGet(DfsKey.camDayPoint) as? NSNumber, camDayPoint.intValue > 0, "남" == ShareData.ins.mySex.rawValue {
                lbMsg.text = NSLocalizedString("activity_txt522", comment: "사진은 검증된 이미지만 등록 됩니다.\n1일 1회 토크 등록시 ") + " \(camDayPoint.stringValue)" + NSLocalizedString("activity_txt446", comment: "P를 적립해 드립니다")
            }
        }
        else if type == .cam {
            if let talkDayPoint = ShareData.ins.dfsGet(DfsKey.talkDayPoint) as? NSNumber, talkDayPoint.intValue > 0, "남" == ShareData.ins.mySex.rawValue {
                lbMsg.text = NSLocalizedString("activity_txt522", comment: "사진은 검증된 이미지만 등록 됩니다.\n1일 1회 토크 등록시 ") + talkDayPoint.stringValue + NSLocalizedString("activity_txt446", comment: "P를 적립해 드립니다")
            }
        }
        btnLink.isHidden = true
        if type == .cam && ShareData.ins.mySex == .femail {
            btnLink.isHidden = false
            let msg = NSLocalizedString("layout_txt14", comment:"영상 채팅으로 적립 받고 환급받는 방법을 알아보기")
            let attr = NSAttributedString.init(string: msg, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
            btnLink.setAttributedTitle(attr, for: .normal)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnTalk {
            
            var list = [String]()
            if type == .cam {
                list.append(NSLocalizedString("talk_memo_3", comment: "친구가 필요해요"))
                list.append(NSLocalizedString("talk_memo_0", comment: "가입인사드립니다"))
                list.append(NSLocalizedString("talk_memo_2", comment: "먼저 영상 신청해 주세요"))
                list.append(NSLocalizedString("talk_memo_6", comment: "연상이 좋아요"))
                list.append(NSLocalizedString("talk_memo_7", comment: "개인기 봐주세요"))
                list.append(NSLocalizedString("talk_memo_8", comment: "심심해요"))
                list.append(NSLocalizedString("talk_memo_9", comment: "재미있게 채팅 해요"))
                list.append(NSLocalizedString("talk_memo_4", comment: "동갑 친구가 좋아요"))
                list.append(NSLocalizedString("talk_memo_5", comment: "연하가 좋아요"))
            }
            else if type == .talk {
                list.append(NSLocalizedString("talk_memo_8", comment: "심심해요"))
                list.append(NSLocalizedString("talk_memo_12", comment: "영화 볼까요?"))
                list.append(NSLocalizedString("talk_memo_14", comment: "고민 들어 주세요"))
                list.append(NSLocalizedString("talk_memo_11", comment: "차 한잔 할까요"))
                list.append(NSLocalizedString("talk_memo_10", comment: "먼저 메세지 주세요"))
                list.append(NSLocalizedString("talk_memo_13", comment: "대화하다 친해지면 만나요"))
                list.append(NSLocalizedString("talk_memo_5", comment: "연하가 좋아요"))
                list.append(NSLocalizedString("talk_memo_3", comment: "친구가 필요해요"))
                list.append(NSLocalizedString("talk_memo_15", comment: "포토톡 해요"))
                list.append(NSLocalizedString("talk_memo_4", comment: "동갑 친구가 좋아요"))
                list.append(NSLocalizedString("talk_memo_6", comment: "연상이 좋아요"))
                list.append(NSLocalizedString("talk_memo_16", comment: "애인이 필요해요"))
                list.append(NSLocalizedString("talk_memo_0", comment: "가입인사드립니다"))
            }
            
            if list.isEmpty == true { return }
            let vc = PopupListViewController.initWithType(.normal, NSLocalizedString("popup_tilte_select", comment: "선택해주세요."), list, nil) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? String else {
                    return
                }
                
                self.tfMemo.text = selItem
                self.selMemo = TalkMemo.severKey(selItem)
            }
            self.presentPanModal(vc)
        }
        else if sender == btnProfile {
            let vc = PhotoManagerViewController.instantiate(with: type)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnLink {
            ApiManager.ins.requestServiceTerms(mode: "yk6") { (res) in
                let yk = res["yk"].stringValue
                if yk.isEmpty == false {
                    let vc = TermsViewController.init()
                    vc.vcTitle = NSLocalizedString("point_notice", comment: "포인트 적립 방법 안내")
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
                            self.showToastWindow(NSLocalizedString("activity_txt232", comment: "포인트가 적립 되었습니다"))
                        }
                        else if "Y2" == point_save && "남" == ShareData.ins.mySex.rawValue {
                            var point = "0"
                            if let p = ShareData.ins.dfsGet(DfsKey.dayLimitPoint) as? NSNumber {
                                point = p.stringValue
                            }
                            let msg = "\(point.addComma()) " + NSLocalizedString("activity_txt516", comment: "")
                            self.showToast(msg)
                        }
                        else {
                            self.showToastWindow(NSLocalizedString("activity_txt356", comment: "등록완료!!"))
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
                            self.showToastWindow(NSLocalizedString("activity_txt232", comment: "포인트가 적립 되었습니다"))
                        }
                        else if "Y2" == point_save && "남" == ShareData.ins.mySex.rawValue {
                            var point = "0"
                            if let p = ShareData.ins.dfsGet(DfsKey.dayLimitPoint) as? NSNumber {
                                point = p.stringValue
                            }
                            let msg = "\(point.addComma()) " + NSLocalizedString("activity_txt516", comment: "")
                            self.showToast(msg)
                        }
//                        else if "N" == point_save {
//                            self.showToastWindow("1일 1회 적립되었습니다.")
//                        }
//                        else if "W" == point_save {
//                            self.showToastWindow("1일 1회 적립되었습니다.")
//                        }
                        else {
                            self.showToastWindow(NSLocalizedString("activity_txt356", comment: "등록완료!!"))
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
