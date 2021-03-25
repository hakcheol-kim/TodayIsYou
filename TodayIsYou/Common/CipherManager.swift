//
//  CipherManager.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/24.
//

import UIKit

import CryptoSwift
class CipherManager: NSObject {
    static var planPw: String {
        let reversed = String(soup.reversed())
        return "\(reversed)\(today.reverseOf(splitLength: 2))\(soup)"
    }
    class func aes128EncrpytToHex(_ input: String) -> String {
        let data: Array<UInt8> = Array(input.utf8)
        do {
            let ciphertxt = try AES(key: self.planPw, iv: ivBlockSize).encrypt(data).toHexString()
            return ciphertxt
        } catch {
            print(error)
            return ""
        }
    }
    class func aes128Decrypt(toHex :String) ->String {
        do {
            let decrypted = try AES(key: self.planPw, iv: ivBlockSize).decrypt(Array(hex: toHex))
            guard let plantxt = String(bytes: decrypted, encoding: .utf8) else {
                return ""
            }
            return plantxt
        } catch {
            print(error)
            return ""
        }
    }
}
