//
//  ProfanityFilter.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/21.
//

import UIKit

class ProfanityFilter: NSObject {

    static let ins = ProfanityFilter()
    private override init() {}

    private let dirtyWords = "바보|멍청이|카톡|카똑|라인|까톡|까똑|카토|ㅋㅌ|catok|ㅋㅏ|ㅋ ㅏ|카뚝|캬뚝|섹스|쎅스|sex"

    private func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    public func cleanUp(_ string: String) -> String {
        let dirtyWords = matches(for: self.dirtyWords, in: string)

        if dirtyWords.count == 0 {
            return string
        } else {
            var newString = string

            dirtyWords.forEach({ dirtyWord in
                let newWord = String(repeating: "😲", count: dirtyWord.count)
                newString = newString.replacingOccurrences(of: dirtyWord, with: newWord, options: [.caseInsensitive])
            })
            return newString
        }
    }
}
