//
//  WKWebView+Extension.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/22.
//

import Foundation
import WebKit

extension WKWebView {
    func cleanAllCookies(_ completion:@escaping()->Void) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { recodes in
            recodes.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) { }
                print("Cookie ::: \(record) deleted")
            }
            completion()
        }
    }
    
    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
    }
}
