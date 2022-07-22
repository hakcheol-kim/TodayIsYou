//
//  CallingModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/05/18.
//

import Foundation
struct CallingModel: Codability {
    var msg_cmd: String = ""
    var from_user_id: String = ""
    var from_user_gender: String = ""
    var from_user_name: String = ""
    var from_user_age: String = ""
    var from_user_img: String = ""
    var from_user_good_cnt: Int = 0
    var from_user_score: Float = 0.0
    var from_user_contents: String = ""
    
    var to_user_name: String = ""
    var to_user_id: String = ""
    var room_key: String = ""
    var message_key: String = ""
    var msg: String = ""
    
    enum CodingKeys: String, CodingKey {
        case msg_cmd
        case from_user_id
        case from_user_gender
        case from_user_name
        case from_user_age
        case from_user_img
        case from_user_good_cnt
        case from_user_score
        case from_user_contents
        case to_user_name
        case to_user_id
        case room_key
        case message_key
        case msg
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.msg_cmd = try values.decodeIfPresent(String.self, forKey: .msg_cmd) ?? ""
        self.from_user_id = try values.decodeIfPresent(String.self, forKey: .from_user_id) ?? ""
        self.from_user_gender = try values.decodeIfPresent(String.self, forKey: .from_user_gender) ?? ""
        self.from_user_name = try values.decodeIfPresent(String.self, forKey: .from_user_name) ?? ""
        self.from_user_age = try values.decodeIfPresent(String.self, forKey: .from_user_age) ?? ""
        self.from_user_img = try values.decodeIfPresent(String.self, forKey: .from_user_img) ?? ""
        do {
            self.from_user_good_cnt = Int(try values.decodeIfPresent(String.self, forKey: .from_user_score) ?? "0") ?? 0
        } catch {
            self.from_user_good_cnt = try values.decodeIfPresent(Int.self, forKey: .from_user_good_cnt) ?? 0
        }
        do {
            self.from_user_score = Float(try values.decodeIfPresent(String.self, forKey: .from_user_score) ?? "0.0") ?? 0.0
        }
        catch {
            self.from_user_score = try values.decodeIfPresent(Float.self, forKey: .from_user_score) ?? 0.0
        }
        self.from_user_contents = try values.decodeIfPresent(String.self, forKey: .from_user_contents) ?? ""
        self.to_user_name = try values.decodeIfPresent(String.self, forKey: .to_user_name) ?? ""
        self.to_user_id = try values.decodeIfPresent(String.self, forKey: .to_user_id) ?? ""
        self.room_key = try values.decodeIfPresent(String.self, forKey: .room_key) ?? ""
        self.message_key = try values.decodeIfPresent(String.self, forKey: .message_key) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
    }
}

