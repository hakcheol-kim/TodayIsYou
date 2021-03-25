//
//  ShareData.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/10.
//

import UIKit

class ShareData: NSObject {
    static let ins = ShareData()
    var userId: String = ""
    var mySex: Gender = .mail
    var myPoint: NSNumber? = nil
    
    func dfsSetValue(_ value: Any?, forKey key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
        if key == DfsKey.myPoint {
            myPoint = value as? NSNumber
        }
    }
    func dfsObjectForKey(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
}
