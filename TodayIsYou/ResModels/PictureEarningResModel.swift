//
//  PictureEarningResModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/07.
//

import Foundation
struct PictureEarningModel: Codability {
    let seq: String
    let user_id: String
    let user_name: String
    let pb_url: String
    let bo_point: Int
    let bo_reg_date: String
    let bp_subject: String
    
    enum CodingKeys: String, CodingKey {
        case seq
        case user_id
        case user_name
        case pb_url
        case bo_point
        case bo_reg_date
        case bp_subject
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.seq = try values.decodeIfPresent(String.self, forKey: .seq) ?? ""
        self.user_id = try values.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        self.pb_url = try values.decodeIfPresent(String.self, forKey: .pb_url) ?? ""
        do {
            self.bo_point = Int(try values.decodeIfPresent(String.self, forKey: .bo_point) ?? "0") ?? 0
        }
        catch {
            self.bo_point = try values.decodeIfPresent(Int.self, forKey: .bo_point) ?? 0
        }
        self.bo_reg_date = try values.decodeIfPresent(String.self, forKey: .bo_reg_date) ?? ""
        self.bp_subject = try values.decodeIfPresent(String.self, forKey: .bp_subject) ?? ""
    }
}

struct PictureEarningResModel: Codability {
    let code: String
    let msg: String
    let bb_tcnt: Int
    let sum: Int
    let page_cnt: Int
    let bb_list: [PictureEarningModel]
    
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case bb_tcnt
        case sum
        case page_cnt
        case bb_list
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
        do {
            self.bb_tcnt = Int(try values.decodeIfPresent(String.self, forKey: .bb_tcnt) ?? "0") ?? 0
        }
        catch {
            self.bb_tcnt = try values.decodeIfPresent(Int.self, forKey: .bb_tcnt) ?? 0
        }
        do {
            self.sum = Int(try values.decodeIfPresent(String.self, forKey: .sum) ?? "0") ?? 0
        } catch {
            self.sum = try values.decodeIfPresent(Int.self, forKey: .sum) ?? 0
        }
        self.page_cnt = try values.decodeIfPresent(Int.self, forKey: .page_cnt) ?? 0
        self.bb_list = try values.decodeIfPresent([PictureEarningModel].self, forKey: .bb_list) ?? []
    }
}
