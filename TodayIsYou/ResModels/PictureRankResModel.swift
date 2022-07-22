//
//  PictureRankResModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/27.
//

import Foundation

struct PictureRank: Codability {
    let num: Int
    let user_id: String
    let user_age: String
    let user_name: String
    let contents: String
    let user_img: String
    let cnt: Int
    
    enum CodingKeys: String, CodingKey {
        case num
        case user_id
        case user_age
        case user_name
        case contents
        case user_img
        case cnt
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.num = try values.decodeIfPresent(Int.self, forKey: .num) ?? 0
        self.user_id = try values.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        self.user_age = try values.decodeIfPresent(String.self, forKey: .user_age) ?? ""
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        self.contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
        let urlStr = try values.decodeIfPresent(String.self, forKey: .user_img) ?? ""
        if let encodedString = urlStr.removingPercentEncoding {
            self.user_img = encodedString
        } else {
            self.user_img = ""
        }
        let cntStr = try values.decodeIfPresent(String.self, forKey: .cnt) ?? "0"
        self.cnt = Int(cntStr) ?? 0
    }
}
struct PictureRankResModel: Codability {
    let code: String
    let msg: String
    let r_list: [PictureRank]
    
    enum CodingKeys: String, CodingKey {
        case code, msg, r_list
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
        self.r_list = try values.decodeIfPresent([PictureRank].self, forKey: .r_list) ?? []
    }
}
