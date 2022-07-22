//
//  PictureDetailResModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/26.
//

import Foundation

struct PictureDetail: Codability {
    let bp_subject: String    //화보 제목
    let user_name: String    //닉네임
    let user_age: String    //나이
    let user_img: String    //프로필이미지경로
    let bp_vod_url: String
    let bp_point: Int    //구매 포인트
    let bp_adult: String    //성인여부    Y,N
    let bp_type: String    //화보타입    P(포토),V(동영상),S(세트)
    let bp_reg_date: String    //등록일시
    let edit_yn: String    //수정여부    Y,N
    let purchase_status: String    //구매여부    Y,N
    let friend_cnt: String    //찜등록여부    Y,N
    let zzim_seq: Int    //찜고유seq값    찜삭제시 해당 seq 값 전달
    let pb_count: Int
    let my_point: Int
    let pb_url_arr: [String]
    
    enum CodingKeys: String, CodingKey {
        case bp_subject
        case user_name
        case user_age
        case user_img
        case bp_vod_url
        case bp_point
        case bp_adult
        case bp_type
        case bp_reg_date
        case edit_yn
        case purchase_status
        case friend_cnt
        case zzim_seq
        case pb_count
        case my_point
        case pb_url_arr
        
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.bp_subject = try values.decodeIfPresent(String.self, forKey: .bp_subject) ?? ""
        self.user_name = try values.decodeIfPresent(String.self, forKey: .user_name) ?? ""
        self.user_age = try values.decodeIfPresent(String.self, forKey: .user_age) ?? ""
        self.user_img = try (values.decodeIfPresent(String.self, forKey: .user_img) ?? "").removingPercentEncoding ?? ""
        self.bp_adult = try values.decodeIfPresent(String.self, forKey: .bp_adult) ?? ""
        self.bp_type = try values.decodeIfPresent(String.self, forKey: .bp_type) ?? ""
        self.bp_reg_date = try values.decodeIfPresent(String.self, forKey: .bp_reg_date) ?? ""
        self.edit_yn = try values.decodeIfPresent(String.self, forKey: .edit_yn) ?? ""
        self.purchase_status = try values.decodeIfPresent(String.self, forKey: .purchase_status) ?? ""
        self.friend_cnt = try values.decodeIfPresent(String.self, forKey: .friend_cnt) ?? ""
        self.bp_vod_url = try (values.decodeIfPresent(String.self, forKey: .bp_vod_url) ?? "").removingPercentEncoding ?? ""
        do {
            self.bp_point = try (values.decodeIfPresent(Int.self, forKey: .bp_point) ?? 0)
        } catch {
            self.bp_point = Int (try (values.decodeIfPresent(String.self, forKey: .bp_point) ?? "0")) ?? 0
        }
        
        do {
            self.zzim_seq = try (values.decodeIfPresent(Int.self, forKey: .zzim_seq) ?? 0)
        } catch {
            self.zzim_seq = Int (try (values.decodeIfPresent(String.self, forKey: .zzim_seq) ?? "0")) ?? 0
        }
        
        do {
            self.pb_count = try (values.decodeIfPresent(Int.self, forKey: .pb_count) ?? 0)
        } catch {
            self.pb_count = Int (try (values.decodeIfPresent(String.self, forKey: .pb_count) ?? "0")) ?? 0
        }
        
        do {
            self.my_point = try (values.decodeIfPresent(Int.self, forKey: .my_point) ?? 0)
        } catch {
            self.my_point = Int (try (values.decodeIfPresent(String.self, forKey: .my_point) ?? "0")) ?? 0
        }
        self.pb_url_arr = try values.decodeIfPresent([String].self, forKey: .pb_url_arr) ?? []
    }
}

struct PictureDetailResModel: Codability {
    let code: String
    let msg: String
    let data: PictureDetail?
    
    enum CodingKeys: String, CodingKey {
        case code, msg, data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
        self.data = try values.decodeIfPresent(PictureDetail.self, forKey: .data)
    }
}
