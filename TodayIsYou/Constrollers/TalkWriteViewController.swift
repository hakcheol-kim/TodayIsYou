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
    
    func requestMyTalk() {
        ApiManager.ins.requestMyTalk(param: ["user_id":ShareData.ins.userId]) { (res) in
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
    func requestMyImgTalk() {
        ApiManager.ins.requestMyImgTalk(param: ["user_id":ShareData.ins.userId]) { (res) in
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
        if let url = Utility.thumbnailUrl(ShareData.ins.userId, user_img), let ivProfile = btnProfile.viewWithTag(100) as? UIImageView {
            ivProfile.setImageCache(url: url, placeholderImgName: nil)
        }
        
        lbMsg.text = "사진은 검증된 이미지만 등록 됩니다."
        if type == .cam {
            if let camDayPoint = ShareData.ins.dfsObjectForKey(DfsKey.camDayPoint) as? NSNumber, camDayPoint.intValue > 0, "남" == ShareData.ins.userSex.rawValue {
                lbMsg.text = "사진은 검증된 이미지만 등록 됩니다.\n1일 1회 토크 등록시 " + camDayPoint.stringValue + "P를 적립해 드립니다"
            }
        }
        else if type == .cam {
            if let talkDayPoint = ShareData.ins.dfsObjectForKey(DfsKey.talkDayPoint) as? NSNumber, talkDayPoint.intValue > 0, "남" == ShareData.ins.userSex.rawValue {
                lbMsg.text = "사진은 검증된 이미지만 등록 됩니다.\n1일 1회 토크 등록시 " + talkDayPoint.stringValue + "P를 적립해 드립니다"
            }
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
            let vc = storyboard?.instantiateViewController(identifier: "PhotoManagerViewController") as! PhotoManagerViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnRegiTalk {
            
        }
    }
}
