//
//  PicturePurchasedResModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/16.
//

import Foundation
struct PicturePurchasedModel: Codability {
    let seq: String
    let user_id: String
    let pb_url: String
    let bp_subject: String
    let user_name: String
    let bo_point: Int
    let bo_reg_date: String
    
    enum CodingKeys: String, CodingKey {
        case seq
        case user_id
        case pb_url
        case bp_subject
        case user_name
        case bo_point
        case bo_reg_date
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.seq = try values.decodeIfPresent(String.self, forKey: .seq) ?? ""
        self.user_id = try values.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        self.pb_url = try values.decodeIfPresent(String.self, forKey: .pb_url) ?? ""
        self.bp_subject = try values.decodeIfPresent(String.self, forKey: .bp_subject) ?? ""
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        self.bo_point = Int(try values.decodeIfPresent(String.self, forKey: .bo_point) ?? "0") ?? 0
        self.bo_reg_date = try values.decodeIfPresent(String.self, forKey: .bo_reg_date) ?? ""
    }
}

struct PicturePurchasedResModel: Codability {
    let code: String
    let msg: String
    let page_cnt: Int
    let bb_list: [PicturePurchasedModel]
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case page_cnt
        case bb_list
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
        self.page_cnt = try values.decodeIfPresent(Int.self, forKey: .page_cnt) ?? 0
        self.bb_list = try values.decodeIfPresent([PicturePurchasedModel].self, forKey: .bb_list) ?? []
    }
}
