//
//  PictorialResponseModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/24.
//

import Foundation
import UIKit
struct PictureModel: Codability {
    let seq: String
    let user_id: String
    let cnt: String
    let user_name: String
    let user_age: String
    let user_img: String
    let pb_url: String
    let bp_subject: String
    let bp_point: Int
    let bp_adult: String
    let bp_type: String
    let bp_reg_date: String
    let ol_cnt: Int //0 : 미구매 / 그외 : 구매
    var height: CGFloat = 0.0
    
    enum CodingKeys: String, CodingKey {
        case seq
        case user_id
        case cnt
        case user_name
        case pb_url
        case bp_subject
        case bp_point
        case bp_adult
        case bp_type
        case bp_reg_date
        case user_age
        case user_img
        case ol_cnt
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.seq = try values.decodeIfPresent(String.self, forKey: .seq) ?? ""
        self.user_id = try values.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        self.cnt = try values.decodeIfPresent(String.self, forKey: .cnt) ?? ""
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        let urlStr = try values.decodeIfPresent(String.self, forKey: .pb_url) ?? ""
        if let encodedString = urlStr.removingPercentEncoding {
            self.pb_url = encodedString
        } else {
            self.pb_url = ""
        }
        self.bp_subject = try values.decodeIfPresent(String.self, forKey: .bp_subject) ?? ""
        let pointStr = try values.decodeIfPresent(String.self, forKey: .bp_point) ?? "0"
        self.bp_point = Int(pointStr) ?? 0
        self.bp_adult = try values.decodeIfPresent(String.self, forKey: .bp_adult) ?? ""
        self.bp_type = try values.decodeIfPresent(String.self, forKey: .bp_type) ?? ""
        self.bp_reg_date = try values.decodeIfPresent(String.self, forKey: .bp_reg_date) ?? ""
        self.user_age = try values.decodeIfPresent(String.self, forKey: .user_age) ?? ""
        self.user_img = try (values.decodeIfPresent(String.self, forKey: .user_img) ?? "").removingPercentEncoding ?? ""
        self.ol_cnt = try Int(values.decodeIfPresent(String.self, forKey: .ol_cnt) ?? "0") ?? 0
    }
}
struct PictureResModel: Codability {
    let code: String
    let msg: String
    let sa_yn: String
    let page_cnt: Int
    let bb_list: [PictureModel]
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case sa_yn
        case page_cnt
        case bb_list
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
        self.sa_yn = try values.decodeIfPresent(String.self, forKey: .sa_yn) ?? ""
        self.page_cnt = try values.decodeIfPresent(Int.self, forKey: .page_cnt) ?? 0
        self.bb_list = try values.decodeIfPresent([PictureModel].self, forKey: .bb_list) ?? []
    }
}
