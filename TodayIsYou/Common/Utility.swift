//
//  Utility.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/10.
//

import UIKit
import CryptoSwift

class Utility: NSObject {
    class func isEdgePhone() -> Bool {
        return ((AppDelegate.ins.window?.safeAreaInsets.bottom)! > 0.0)
    }
    class func thumbnailUrl(_ userId: String?, _ fileName: String?) ->String? {
        guard let userId = userId, let fileName = fileName, userId.isEmpty == false, fileName.isEmpty == false  else {
            return nil
        }
        var url = "\(baseUrl)/upload/talk/\(userId)/thum/thum_\(fileName)"
        url = url.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if url.isEmpty == false {
//            print("url: \(url)")
        }
        return url
    }
    class func originImgUrl(_ userId: String?, _ fileName: String?) ->String? {
        guard let userId = userId, let fileName = fileName, userId.isEmpty == false, fileName.isEmpty == false  else {
            return nil
        }
        var url = "\(baseUrl)/upload/talk/\(userId)/\(fileName)"
        url = url.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return url
    }
    class func createUserId(_ input:String) -> String {
        return input.md5()
    }
    class func getCurrentDate(format:String) -> String {
        let df = CDateFormatter.init()
        df.dateFormat = format
        let dateStr = df.string(from: Date())
        return dateStr
    }
    
}
