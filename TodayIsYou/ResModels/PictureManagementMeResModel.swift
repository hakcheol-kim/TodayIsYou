//
//  PictureManagementMeResModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/07.
//

import Foundation

struct PictureManagementMeModel: Codability {
    let seq: String
    let user_id: String
    let user_name: String
    let pb_url: String
    let bp_subject: String
    let bp_point: Int
    let bp_adult: String
    let bp_type: String
    let bp_inspect: Int
    let sum_bo_point: Int
    let bp_reg_date: String
    
    enum CodingKeys: String, CodingKey {
        case seq
        case user_id
        case user_name
        case pb_url
        case bp_subject
        case bp_point
        case bp_adult
        case bp_type
        case bp_inspect
        case sum_bo_point
        case bp_reg_date
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.seq = try values.decodeIfPresent(String.self, forKey: .seq) ?? ""
        self.user_id = try values.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        self.pb_url = try values.decodeIfPresent(String.self, forKey: .pb_url) ?? ""
        self.bp_subject = try values.decodeIfPresent(String.self, forKey: .bp_subject) ?? ""
        self.bp_point = try Int(values.decodeIfPresent(String.self, forKey: .bp_point) ?? "0") ?? 0
        self.bp_adult = try values.decodeIfPresent(String.self, forKey: .bp_adult) ?? ""
        self.bp_type = try values.decodeIfPresent(String.self, forKey: .bp_type) ?? ""
        self.bp_inspect = try Int(values.decodeIfPresent(String.self, forKey: .bp_inspect) ?? "0") ?? 0
        self.sum_bo_point = try Int(values.decodeIfPresent(String.self, forKey: .sum_bo_point) ?? "0") ?? 0
        self.bp_reg_date = try values.decodeIfPresent(String.self, forKey: .bp_reg_date) ?? ""
    }
}

struct PictureManagementMeResModel: Codability {
    let code: String
    let msg: String
    let cnt: Int
    let user_img: String
    let user_name: String
    let user_age: String
    let contents: String
    let fw_cnt: Int
    let page_cnt: Int
    let bb_list: [PictureManagementMeModel]
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case cnt
        case user_img
        case user_name
        case user_age
        case contents
        case fw_cnt
        case page_cnt
        case bb_list
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
        self.cnt = try Int(values.decodeIfPresent(String.self, forKey: .cnt) ?? "0") ?? 0
        self.user_img = try values.decodeIfPresent(String.self, forKey: .user_img) ?? ""
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        self.user_age = try values.decodeIfPresent(String.self, forKey: .user_age) ?? ""
        self.contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
        self.fw_cnt = try Int(values.decodeIfPresent(String.self, forKey: .fw_cnt) ?? "0") ?? 0
        self.page_cnt = try values.decodeIfPresent(Int.self, forKey: .page_cnt) ?? 0
        self.bb_list = try values.decodeIfPresent([PictureManagementMeModel].self, forKey: .bb_list) ?? []
    }
}
        
        


