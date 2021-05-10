//
//  ShareData.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/10.
//

import UIKit
import SwiftyJSON

class ShareData: NSObject {
    static let ins = ShareData()
    var myId: String = ""
    var mySex: Gender = .mail
    var myName:String = ""
    var myPoint: NSNumber? = nil
    
    func dfsSet(_ value: Any?, _ key: String?) {
        guard let key = key, let value = value  else {
            return
        }
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
        if key == DfsKey.userPoint {
            myPoint = value as? NSNumber
        }
    }
    func dfsGet(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    func dfsRemove(_ key:String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func setUserInfo(_ user:JSON) {
        let user_id = user["user_id"].stringValue
        let user_name = user["user_name"].stringValue
        let user_point = user["user_point"].numberValue
        let user_area = user["user_area"].stringValue
        let user_sex = user["user_sex"].stringValue
        let noti_yn = user["noti_yn"].stringValue
        let user_score = user["user_score"].numberValue
        let user_age = user["user_age"].stringValue
        let good_cnt = user["good_cnt"].numberValue
        let user_bbs_point = user["user_bbs_point"].numberValue
        let user_img = user["user_img"].stringValue
        let talk_user_img = user["talk_user_img"].stringValue
        let cam_user_img = user["cam_user_img"].stringValue
        let connect_push = user["connect_push"].stringValue
        let inapp_cnt = user["inapp_cnt"].numberValue
        
        let dfs = UserDefaults.standard
        dfs.setValue(user_id, forKey: DfsKey.userId)
        dfs.setValue(user_name, forKey: DfsKey.userName)
        dfs.setValue(user_area, forKey: DfsKey.userArea)
        dfs.setValue(user_sex, forKey: DfsKey.userSex)
        dfs.setValue(noti_yn, forKey: DfsKey.notiYn)
        dfs.setValue(user_age, forKey: DfsKey.userAge)
        dfs.setValue(user_point, forKey: DfsKey.userPoint)
        dfs.setValue(user_score, forKey: DfsKey.userScore)
        dfs.setValue(good_cnt, forKey: DfsKey.goodCnt)
        dfs.setValue(user_bbs_point, forKey: DfsKey.userBbsPoint)
        dfs.setValue(user_img, forKey: DfsKey.userImg)
        dfs.setValue(talk_user_img, forKey: DfsKey.talkUserImg)
        dfs.setValue(cam_user_img, forKey: DfsKey.camUserImg)
        dfs.setValue(connect_push, forKey: DfsKey.connectPush)
        dfs.setValue(inapp_cnt, forKey: DfsKey.inappCnt)
        
        self.myId = user_id
        self.myPoint = user_point
        self.myName = user_name
        
        if user_sex == "남" {
            self.mySex = Gender.mail
        }
        else {
            self.mySex = Gender.femail
        }
        
        dfs.synchronize()
    }
    
    func setHomePoint(_ info:JSON) {
        let phone_out_start_point = info["phone_out_start_point"].numberValue // ": 600,
        let cam_out_user_point = info["cam_out_user_point"].numberValue // ": 200,
        let cam_out_start_point = info["cam_out_start_point"].numberValue // ": 1200,
        let photo_view_point = info["photo_view_point"].numberValue // ": 0,
        let random_msg_out_point = info["random_msg_out_point"].numberValue // ": 0,
        let day_limit_point = info["day_limit_point"].numberValue // ": 10000000,
        let cam_day_point = info["cam_day_point"].numberValue // ": 50,
        let photo_day_point = info["photo_day_point"].numberValue // ": 50,
        let talk_msg_out_point = info["talk_msg_out_point"].numberValue // ": 90,
        let day_login_point = info["day_login_point"].numberValue // ": 50,
        let phone_msg_out_point = info["phone_msg_out_point"].numberValue // ": 0,
        let block_cnt = info["block_cnt"].numberValue // ": 0,
        let talk_day_point = info["talk_day_point"].numberValue // ": 50,
        let phone_out_user_point = info["phone_out_user_point"].numberValue // ": 100,
        let user_r = info["user_r"].numberValue // ": 0,
        let user_point = info["user_point"].numberValue // ": 100002000,
        let phone_in_user_point = info["phone_in_user_point"].numberValue // ": 70,
        let cam_msg_out_point = info["cam_msg_out_point"].numberValue // ": 0,
        let cam_play_point = info["cam_play_point"].numberValue // ": 0,
        
        let dfs = UserDefaults.standard
        dfs.setValue(phone_out_start_point, forKey: DfsKey.phoneOutStartPoint)
        dfs.setValue(cam_out_user_point, forKey: DfsKey.camOutUserPoint)
        dfs.setValue(cam_out_start_point, forKey: DfsKey.camOutStartPoint)
        dfs.setValue(photo_view_point, forKey: DfsKey.photoViewPoint)
        dfs.setValue(random_msg_out_point, forKey: DfsKey.randomMsgOutPoint)
        dfs.setValue(day_limit_point, forKey: DfsKey.dayLimitPoint)
        dfs.setValue(cam_day_point, forKey: DfsKey.camDayPoint)
        dfs.setValue(photo_day_point, forKey: DfsKey.photoDayPoint)
        dfs.setValue(talk_msg_out_point, forKey: DfsKey.talkMsgOutPoint)
        dfs.setValue(day_login_point, forKey: DfsKey.dayLoginPoint)
        dfs.setValue(phone_msg_out_point, forKey: DfsKey.phoneMsgOutPoint)
        dfs.setValue(block_cnt, forKey: DfsKey.blockCnt)
        dfs.setValue(talk_day_point, forKey: DfsKey.talkDayPoint)
        dfs.setValue(phone_out_user_point, forKey: DfsKey.phoneOutUserPoint)
        dfs.setValue(user_r, forKey: DfsKey.userR)
        dfs.setValue(user_point, forKey: DfsKey.userPoint)
        dfs.setValue(phone_in_user_point, forKey: DfsKey.phoneInUserPoint)
        dfs.setValue(cam_msg_out_point, forKey: DfsKey.camMsgOutPoint)
        dfs.setValue(cam_play_point, forKey: DfsKey.camPlayPoint)
        
        dfs.synchronize()
    }
    
    func getAge() ->[String]? {
        guard let filePath = Bundle.main.path(forResource: "StaticData", ofType: "plist"),
              let rootDic = NSDictionary(contentsOfFile: filePath) as? Dictionary<String, Any>,
              let age = rootDic["age"] as? [String] else {
            return nil
        }
        return age
    }
    func getArea() ->[String]? {
        guard let filePath = Bundle.main.path(forResource: "StaticData", ofType: "plist"),
              let rootDic = NSDictionary(contentsOfFile: filePath) as? Dictionary<String, Any>,
              let area = rootDic["area"] as? [String] else {
            return nil
        }
        return area
    }
    func getCamTalkMemo() ->[String]? {
        guard let filePath = Bundle.main.path(forResource: "StaticData", ofType: "plist"),
              let rootDic = NSDictionary(contentsOfFile: filePath) as? Dictionary<String, Any>,
              let array = rootDic["cam_talk_memo"] as? [String] else {
            return nil
        }
        return array
    }
    func getTalkMemo() ->[String]? {
        guard let filePath = Bundle.main.path(forResource: "StaticData", ofType: "plist"),
              let rootDic = NSDictionary(contentsOfFile: filePath) as? Dictionary<String, Any>,
              let array = rootDic["talk_memo"] as? [String] else {
            return nil
        }
        return array
    }
}
