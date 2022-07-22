//
//  PictureAlbumModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/17.
//

import Foundation
import UIKit

struct PictureAlbumModel: Codability {
    let seq: String
    let user_id: String
    let pb_url: String
    let bp_subject: String
    let bp_point: Int
    let bp_adult: String
    let bp_type: String
    let bp_reg_date: String
    let purchase_status: String
    var height: CGFloat = 0.0
    
    enum CodingKeys: String, CodingKey {
        case seq
        case user_id
        case pb_url
        case bp_subject
        case bp_point
        case bp_adult
        case bp_type
        case bp_reg_date
        case purchase_status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.seq = try values.decodeIfPresent(String.self, forKey: .seq) ?? ""
        self.user_id = try values.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        self.pb_url = try values.decodeIfPresent(String.self, forKey: .pb_url) ?? ""
        self.bp_subject = try values.decodeIfPresent(String.self, forKey: .bp_subject) ?? ""
        do {
            self.bp_point = try values.decodeIfPresent(Int.self, forKey: .bp_point) ?? 0
        } catch {
            self.bp_point = Int(try values.decodeIfPresent(String.self, forKey: .bp_point) ?? "0") ?? 0
        }
        self.bp_adult = try values.decodeIfPresent(String.self, forKey: .bp_adult) ?? ""
        self.bp_type = try values.decodeIfPresent(String.self, forKey: .bp_type) ?? ""
        self.bp_reg_date = try values.decodeIfPresent(String.self, forKey: .bp_reg_date) ?? ""
        self.purchase_status = try values.decodeIfPresent(String.self, forKey: .purchase_status) ?? ""
    }
    
}

struct PictureAlbumResModel: Codability {
    let code: String
    let msg: String
    let cnt: Int
    let user_img: String
    let user_name: String
    let user_age: String
    let contents: String
    let fw_cnt: Int
    let friend_cnt: String
    let zzim_seq: Int
    let page_cnt: Int
    
//"code":"000"
//"msg":"success"
//"cnt":"1"
//"user_img":"https:\/\/api.todayisyou.co.kr\/upload\/talk\/bd69655361a9bc66c367f7ff78af7270\/thum\/thum_"
//"user_name":"\uc624\ub611\ud574\uc6a9"
//"user_age":"50\ub300"
//"contents":"\uba3c\uc800 \uba54\uc138\uc9c0 \uc8fc\uc138\uc694"
//"fw_cnt":"0"
//"friend_cnt":"Y"
//"zzim_seq":"9642"
//"page_cnt":1,
    
    let bb_list: [PictureAlbumModel]
    
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case cnt
        case user_img
        case user_name
        case user_age
        case contents
        case fw_cnt
        case friend_cnt
        case zzim_seq
        case page_cnt
        case bb_list
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
        do {
            self.cnt = try values.decodeIfPresent(Int.self, forKey: .cnt) ?? 0
        } catch {
            self.cnt = Int(try values.decodeIfPresent(String.self, forKey: .cnt) ?? "0") ?? 0
        }
        self.user_img = try values.decodeIfPresent(String.self, forKey: .user_img) ?? ""
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        self.user_age = try values.decodeIfPresent(String.self, forKey: .user_age) ?? ""
        self.contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
        do {
            self.fw_cnt = try values.decodeIfPresent(Int.self, forKey: .fw_cnt) ?? 0
        } catch {
            self.fw_cnt = Int(try values.decodeIfPresent(String.self, forKey: .fw_cnt) ?? "0") ?? 0
        }
        
        self.friend_cnt = try values.decodeIfPresent(String.self, forKey: .friend_cnt) ?? ""
        
        do {
            self.zzim_seq = try values.decodeIfPresent(Int.self, forKey: .zzim_seq) ?? 0
        } catch {
            self.zzim_seq = Int(try values.decodeIfPresent(String.self, forKey: .zzim_seq) ?? "0") ?? 0
        }
        
        do {
            self.page_cnt = try values.decodeIfPresent(Int.self, forKey: .page_cnt) ?? 0
        } catch {
            self.page_cnt = Int(try values.decodeIfPresent(String.self, forKey: .page_cnt) ?? "0") ?? 0
        }
        self.bb_list = try values.decodeIfPresent([PictureAlbumModel].self, forKey: .bb_list) ?? []
        
    }
    
}
