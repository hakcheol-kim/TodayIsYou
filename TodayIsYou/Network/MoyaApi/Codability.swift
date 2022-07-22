//
//  Codability.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/24.
//

import Foundation

protocol Codability: Codable {}

extension Codability {
    typealias T = Self
    func encode(to encoder: Encoder) -> Data? {
        return try? JSONEncoder().encode(self)
    }
    static func decode(data: Data) ->T? {
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
