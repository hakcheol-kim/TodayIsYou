//
//  ImgTalkResModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/05/19.
//

import Foundation
struct ImgTalkResModel: Codability {
    let user_sex: String //"남",
    let reg_date: String //"2022-01-13 11:50:55",
    let view_cnt: Int //"0",
    let good_cnt: Int //"1",
    let contents: String //"개인기 봐주세요",
    let user_score: Float //4.0,
    let user_name: String //"총각",
    let user_age: String //"20대",
    let user_img: String //"20220509152840530.jpg",
    let seq: Int //0,
    let isSuccess: String //"01"
    
    enum CodingKeys: String, CodingKey {
        case user_sex
        case reg_date
        case view_cnt
        case good_cnt
        case contents
        case user_score
        case user_name
        case user_age
        case user_img
        case seq
        case isSuccess
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.user_sex = try values.decodeIfPresent(String.self, forKey: .user_sex) ?? ""
        self.reg_date = try values.decodeIfPresent(String.self, forKey: .reg_date) ?? ""
        do {
            self.view_cnt = Int(try values.decodeIfPresent(String.self, forKey: .view_cnt) ?? "0") ?? 0
        } catch {
            self.view_cnt = try values.decodeIfPresent(Int.self, forKey: .view_cnt) ?? 0
        }
        do {
            self.good_cnt = Int(try values.decodeIfPresent(String.self, forKey: .good_cnt) ?? "0") ?? 0
        } catch {
            self.good_cnt = try values.decodeIfPresent(Int.self, forKey: .good_cnt) ?? 0
        }
        
        self.contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
        do {
            self.user_score = Float(try values.decodeIfPresent(String.self, forKey: .user_score) ?? "0") ?? 0
        } catch {
            self.user_score = try values.decodeIfPresent(Float.self, forKey: .user_score) ?? 0
        }
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        self.user_age = try values.decodeIfPresent(String.self, forKey: .user_age) ?? ""
        self.user_img = try values.decodeIfPresent(String.self, forKey: .user_img) ?? ""
        do {
            self.seq = Int(try values.decodeIfPresent(String.self, forKey: .seq) ?? "0") ?? 0
        } catch {
            self.seq = try values.decodeIfPresent(Int.self, forKey: .seq) ?? 0
        }
        self.isSuccess = try values.decodeIfPresent(String.self, forKey: .isSuccess) ?? ""
    }
}

