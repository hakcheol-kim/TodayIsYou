//
//  String+Extension.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/22.
//

import Foundation
import UIKit

extension String {
    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }
    func deletingPrefix(_ prefix: String) -> String {
           guard self.hasPrefix(prefix) else { return self }
           return String(self.dropFirst(prefix.count))
    }
    // String Trim
    public var stringTrim: String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // Return String chracters count
    public var length: Int {
        return self.count
    }
    
    // String localized
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    // String localized with comment
    public func localizedWithComment(comment: String) -> String {
        return NSLocalizedString(self, comment:comment)
    }
    
    // E-mail address validation
    public func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
//    public func validateKorPhoneNumber() -> Bool {
//        let reg = "^[0-9]{3}[-]+[0-9]{4}[-]+[0-9]{4}$"
////        let reg = "^[0-9]{3}+[0-9]{4}+[0-9]{4}$"
//        let predicate = NSPredicate(format:"SELF MATCHES %@", reg)
//        return predicate.evaluate(with: self)
//    }
    public func validateKorPhoneNumber() -> Bool {
        let regx = "^[0-9]{3}+[0-9]{4}+[0-9]{4}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regx)
        return predicate.evaluate(with: self)
    }
    // Password validation
    public func validatePassword() -> Bool {
//        let passwordRegEx = "(?=.*[a-zA-Z])(?=.*[!@#$%^_*-])(?=.*[0-9]).{8,40}"
            //"^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,16}$"
        let passwordRegEx = "(?=.*[a-zA-Z0-9~!@#$%^&*()_+|<>?:{}]).{8,40}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: self)
    }
    public func checkEnglish() ->Bool {
        let reg = "^[a-zA-Z]"
        return NSPredicate(format: "SELF MATCHES %@", reg).evaluate(with: self)
    }
    public func checkNum() ->Bool {
        let reg = "^[0-9]"
        return NSPredicate(format: "SELF MATCHES %@", reg).evaluate(with: self)
    }
    public func checkSpecialPw() ->Bool {
        let reg = "^[~!@#$%^&*()_+ |.<>?:{}]"
        return NSPredicate(format: "SELF MATCHES %@", reg).evaluate(with: self)
    }
    
    // String split return array
    public func arrayBySplit(splitter: String? = nil) -> [String] {
        if let s = splitter {
            return self.components(separatedBy: s)
        } else {
            return self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        }
    }
    
    func getNumberString() ->String? {
        let strArr = self.components(separatedBy: CharacterSet.decimalDigits.inverted)
        var result = ""
        for item in strArr {
            result.append(item)
        }
        return result
    }
    func addComma() ->String {
        let nf = NumberFormatter.init()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        nf.roundingMode = .halfEven
        nf.numberStyle = .decimal
        
        nf.locale = Locale(identifier: "en_US")
        let number = NSNumber.init(value: Double(self)!)
        let result = nf.string(from: number)
        return result ?? ""
    }
    func delComma() ->String {
        var result = self
        result = self.replacingOccurrences(of: " ", with: "")
        result = self.replacingOccurrences(of: ",", with: "")
        result = self.replacingOccurrences(of: ".", with: "")
        return result
    }
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        return results.map { String($0) }
    }
    
    func reverseOf(splitLength length: Int = 0) -> String {
        if length == 0 {
            return String(self.reversed())
        }
        else {
            var result = ""
            let array = self.split(by: length)
            for str in array {
                let reStr = String(str.reversed())
                result.append(reStr)
            }
            return result
        }
    }
    func maskOfSuffixLenght(_ length:Int) -> String? {
        return String(repeating: "✱", count: Swift.max(0, count-length)) + suffix(length)
    }
    func parsingJsonObject() -> [String:Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return json as? [String:Any]
        } catch  {
            return nil
        }
    }
    func subString(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex..<endIndex])
    }
}
