//
//  Extension.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import Foundation
import UIKit
import AlamofireImage
import CoreGraphics
import SwiftyJSON

//FIXME:: UITableView
extension UITableView {
    func reloadData(completion:@escaping ()-> Void) {
        UIView.animate(withDuration: 0) {
            self.reloadData()
        } completion: { (finish) in
            completion()
        }
    }
}

extension UICollectionView {
    func reloadData(completion:@escaping ()-> Void) {
        UIView.animate(withDuration: 0) {
            self.reloadData()
        } completion: { (finish) in
            completion()
        }
    }
}

//FIXME:: CACornerMask
extension CACornerMask {
    init(TL: Bool = false, TR: Bool = false, BL: Bool = false, BR: Bool = false) {
        var value: UInt = 0
        if TL { value += 1 }
        if TR { value += 2 }
        if BL { value += 4 }
        if BR { value += 8 }

        self.init(rawValue: value)
    }
}
extension UIColor {
    convenience init(hex: UInt) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0x00FF00) >> 8) / 255.0, blue: CGFloat(hex & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
}

//FIXME:: Error
public extension Error {
    var localizedDescription: String {
        return NSError(domain: _domain, code: _code, userInfo: nil).localizedDescription
    }
}

extension NSAttributedString {
    convenience init(htmlString html: String) throws {
        try self.init(data: Data(html.utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil)
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

extension Locale {
    var languageCode: String {
        let localId = NSLocale.preferredLanguages[0] as String
        let info = NSLocale.components(fromLocaleIdentifier: localId)
        guard let language = info["kCFLocaleLanguageCodeKey"] else {
            return ""
        }
        return language
    }
    var countryCode: String {
        let localId = NSLocale.preferredLanguages[0] as String
        let info = NSLocale.components(fromLocaleIdentifier: localId)
        guard let language = info["kCFLocaleCountryCodeKey"] else {
            return ""
        }
        return language
    }
}
extension NSNumber {
    func toString(_ minDigit:Int = 0, _ maxDigit:Int = 2) -> String {
        let nf = NumberFormatter.init()
        nf.minimumFractionDigits = minDigit
        nf.maximumFractionDigits = maxDigit
        nf.roundingMode = .halfEven
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "en_US")
        
        guard let result = nf.string(from: self) else {
            return ""
        }
        return result
    }
   
}
