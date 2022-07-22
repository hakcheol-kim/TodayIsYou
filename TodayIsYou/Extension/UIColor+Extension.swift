//
//  UIColor+Extension.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/18.
//

import Foundation
import UIKit

enum AssetColor {
    case appColor
    case blackText
    case gray102
    case gray120
    case gray125
    case gray204
    case gray221
    case gray224
    case gray225
    case grayBg241
    case grayButtonBg
    case naviDrak
    case naviLight
    case naviMiddle
    case redLight
    case redMiddle
    case redText
    case whiteBg
    case whiteText
    case yellowLight
    case blueLight
    case blackAlpa20
    case blackAlpa30
    case darkRedText
    case gray170
    case yellow
    case pingLight
}

extension UIColor {
    static func appColor(_ name: AssetColor) -> UIColor {
        switch name {
        case .appColor:
            return UIColor(named: "appColor")!
        case .blackText:
            return UIColor(named: "blackText")!
        case .gray102:
            return UIColor(named: "gray102")!
        case .gray120:
            return UIColor(named: "gray120")!
        case .gray125:
            return UIColor(named: "gray125")!
        case .gray204:
            return UIColor(named: "gray204")!
        case .gray221:
            return UIColor(named: "gray221")!
        case .gray224:
            return UIColor(named: "gray224")!
        case .gray225:
            return UIColor(named: "gray225")!
        case .grayBg241:
            return UIColor(named: "grayBg241")!
        case .grayButtonBg:
            return UIColor(named: "grayButtonBg")!
        case .naviDrak:
            return UIColor(named: "naviDrak")!
        case .naviLight:
            return UIColor(named: "naviLight")!
        case .naviMiddle:
            return UIColor(named: "naviMiddle")!
        case .redLight:
            return UIColor(named: "redLight")!
        case .redMiddle:
            return UIColor(named: "redMiddle")!
        case .redText:
            return UIColor(named: "redText")!
        case .whiteBg:
            return UIColor(named: "whiteBg")!
        case .whiteText:
            return UIColor(named: "whiteText")!
        case .yellowLight:
            return UIColor(named: "yellowLight")!
        case .blueLight:
            return UIColor(named: "blueLight")!
        case .blackAlpa20:
            return UIColor(named: "blackAlpa20")!
        case .blackAlpa30:
            return UIColor(named: "blackAlpa30")!
        case .darkRedText:
            return UIColor(named: "darkRedText")!
        case .gray170:
            return UIColor(named: "gray170")!
        case .yellow:
            return UIColor(named: "yellow")!
        case .pingLight:
            return UIColor(named: "pingLight")!
        }
        
    }
}
