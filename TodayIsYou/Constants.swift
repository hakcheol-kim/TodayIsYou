//
//  Constants.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/05.
//

import Foundation

import UIKit

let baseUrl = "https://api.ohguohgu.com/api"
let hostUrl = "v2"

public func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
public func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 1.0)
}

let ColorAppDefault = RGB(139, 0, 255)
let ColorBorderDefault = RGB(221, 221, 221)

let IsShowTutorial = "IsShowTutorial"
let kPushSetting = "PushSetting"
let kPushUserData = "PushUserData"

let kMemId = "MemId"
let kMemJoinType = "MemJoinType"
let kMemUserId = "MemUserId"
let kMemUserName = "MemUserName"
let kMemNickName = "MemNickName"
