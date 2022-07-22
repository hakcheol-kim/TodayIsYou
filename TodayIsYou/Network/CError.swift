//
//  CError.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/16.
//

import Foundation

enum CError: Error, LocalizedError {
    case unknown
    case apiError(message: String)
    case parserError(message: String)
    case networkError(form: URLError)
    case customError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("activity_txt544", comment: "네트워크 연결오류")
        case .apiError(let message), .parserError(let message), .customError(let message):
            return message
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}
