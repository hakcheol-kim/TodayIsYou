//
//  Bundle+Extension.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/22.
//

import Foundation

extension Bundle {
    /// 앱 이름
    var appName: String {
        if let value = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return value
        }
        return ""
    }
    /// 앱 버전 class
    var appVersion: String {
        if let value = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String { return value
        }
        return ""
    }
    ////// 앱 빌드 버전
    var appBuildVersion: String {
        if let value = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return value
        }
        return ""
    }
    /// 앱 번들 ID
    var bundleIdentifier: String {
        if let value = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
            return value
        }
        return ""
    }
    
    static func swizzleLocalization() {
        let orginalSelector = #selector(localizedString(forKey:value:table:))
        guard let orginalMethod = class_getInstanceMethod(self, orginalSelector) else { return }
        
        let mySelector = #selector(myLocaLizedString(forKey:value:table:))
        guard let myMethod = class_getInstanceMethod(self, mySelector) else { return }
        
        if class_addMethod(self, orginalSelector, method_getImplementation(myMethod), method_getTypeEncoding(myMethod)) {
            class_replaceMethod(self, mySelector, method_getImplementation(orginalMethod), method_getTypeEncoding(orginalMethod))
        } else {
            method_exchangeImplementations(orginalMethod, myMethod)
        }
    }
    
    @objc private func myLocaLizedString(forKey key: String,value: String?, table: String?) -> String {
        let curLanCode = appDelegate.currentLanguage
        var tblCode = curLanCode
        switch curLanCode {
        case "ko":
            tblCode = curLanCode
            break
        case "en":
            tblCode = curLanCode
            break
        case "ja":
            tblCode = curLanCode
            break
        case "zh":
            tblCode = "zh-Hans"
            break
        default:
            tblCode = "Base"
            break
        }
        
        guard let bundlePath = Bundle.main.path(forResource: tblCode, ofType: "lproj"),
              let bundle = Bundle(path: bundlePath) else {
            return Bundle.main.myLocaLizedString(forKey: key, value: value, table: table)
        }
        return bundle.myLocaLizedString(forKey: key, value: value, table: table)
    }
    static func localizeStirng(_ key: String) -> String {
        return Bundle.main.localizedString(forKey: key, value: nil, table: "InfoPlist")
    }
}
