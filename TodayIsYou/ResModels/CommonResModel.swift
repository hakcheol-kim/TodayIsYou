//
//  CommonResModel.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/24.
//

import Foundation
struct CommonResModel: Codability {
    let code: String
    let msg: String
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.msg = try values.decodeIfPresent(String.self, forKey: .msg) ?? ""
    }
}
