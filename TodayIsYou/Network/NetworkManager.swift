//
//  NetworkManager.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/09.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

typealias ResSuccess = (JSON) -> Void
typealias ResFailure = (CError) -> Void

enum AppError: String, Error {
    case invalidResponseType = "response data type not dictionary"
    case reqeustStatusCodeOverRage = "response status code over range 200 ~ 300"
}

enum ContentType: String {
    case json = "application/json;charset=UTF-8"
    case formdata = "multipart/form-data"
    case urlencoded = "application/x-www-form-urlencoded"
    case text = "text/plain"
}

class NetworkManager: NSObject {
    static let ins = NetworkManager()
    
    func getFullUrl(_ url:String) -> String {
        return "\(baseUrl)\(url)"
    }
    
    func request(_ method: HTTPMethod, _ url: String, _ param:[String:Any]?, _ encoding:ParameterEncoding = JSONEncoding.default, _ isStartIndicator:Bool = true,  success:ResSuccess?, failure:ResFailure?) {
        var encoding = encoding
        var fullUrl = ""
        if (url.hasPrefix("http") || url.hasPrefix("https")) {
            fullUrl = url
        }
        else {
            fullUrl = self.getFullUrl(url)
        }
        
        guard let encodedUrl = fullUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        if isStartIndicator {
            appDelegate.startIndicator()
        }
        let languageCode = ShareData.ins.serverLanguageCode.uppercased()
        let customLanguageHeader = HTTPHeader(name: "forgn_lang", value: languageCode)
        
        var header:HTTPHeaders = [.contentType(ContentType.json.rawValue), .accept("application/json"), customLanguageHeader]
        
        if encodedUrl.hasPrefix(baseUrl2+"/app/subs/subs_insert.php") {
            header = [.contentType(ContentType.urlencoded.rawValue), customLanguageHeader]
            encoding = URLEncoding.default
        }
        
//        debugPrint("======= encoding: url: \(encodedUrl)")
        let request = AF.request(encodedUrl, method: method, parameters: param, encoding: encoding, headers: header)
//        AF.session.configuration.timeoutIntervalForRequest = 10
//        AF.session.configuration.timeoutIntervalForResource = 10
        
        request.response { response in
            
            if let printUrl = response.request?.url?.absoluteString,
                let printUrl = printUrl.removingPercentEncoding {
                print("======= request: url: \(printUrl)")
            }
            if let param = param {
                print("======= pram: \(param)")
            }
            if let header = response.request?.headers {
                print("======= header: \(header)")
            }
            
            if isStartIndicator {
                appDelegate.stopIndicator()
            }
            
            switch response.result {
            case .success(let value):
                guard let value = value else {
                    failure?(.unknown)
                    return
                }
                guard let res = response.response, let statusCode = res.statusCode as? Int else {
                    failure?(.unknown)
                    return
                }
                if statusCode == 401 {
                    failure?(.apiError(message: NSLocalizedString("activity_txt542", comment: "서버에러")))
                    return
                }
                
                if statusCode == 404 {
                    failure?(.apiError(message: NSLocalizedString("activity_txt542", comment: "서버에러")))
                    return
                }
                
                if statusCode >= 500 && statusCode < 600 {
                    failure?(.apiError(message: NSLocalizedString("activity_txt543", comment: "서버연결에러")))
                    return
                }
                
                let json = JSON(value)
                let reuslt = json["Result"]
                print("======= response =======")
                debugPrint(json)
                if reuslt.isEmpty == false {
                    success?(reuslt)
                }
                else {
                    success?(json)
                }
                break
            case .failure :
                failure?(.unknown)
                break
            }
        }
    }
    
    func requestFileUpload(_ method: HTTPMethod, _ url: String, _ param:[String:Any]?, success:ResSuccess?, failure:ResFailure?) {
        let fullUrl = self.getFullUrl(url)
        guard let encodedUrl = fullUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let param = param else {
            return
        }
        
        appDelegate.startIndicator()
        
        let languageCode = ShareData.ins.serverLanguageCode.uppercased()
        let customLanguageHeader = HTTPHeader(name: "forgn_lang", value: languageCode)
        let header: HTTPHeaders = [.contentType(ContentType.formdata.rawValue), customLanguageHeader]
        
        print("======= request: url: \(String(describing: encodedUrl.removingPercentEncoding))")
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                if let value = value as? Array<UIImage> {
                    for img in value {
                        if let imgData = img.jpegData(compressionQuality: 0.9) {
                            let strDate = Utility.getCurrentDate(format: "yyyyMMddHHmmssS")
                            multipartFormData.append(imgData, withName: "\(key)[]", fileName: "JPEG_\(strDate).jpg", mimeType: "image/jpg")
                            print(" == imgData byte: \(ByteCountFormatter().string(fromByteCount: Int64(imgData.count)))")
                        }
                    }
                }
                else {
                    if let value = value as? UIImage {
                        if let imgData = value.jpegData(compressionQuality: 0.9) {
                            let strDate = Utility.getCurrentDate(format: "yyyyMMddHHmmssS")
                            multipartFormData.append(imgData, withName: "\(key)", fileName: "JPEG_\(strDate).jpg", mimeType: "image/jpg")
                            print(" == imgData byte: \(ByteCountFormatter().string(fromByteCount: Int64(imgData.count)))")
                        }
                    }
                    else {
                        let data:Data? = "\(value)".data(using: .utf8)
                        if let data = data {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }
            }
        }, to: encodedUrl, method: method, headers: header).response { response in
            appDelegate.stopIndicator()
            
            switch response.result {
            case .success(let value):
                guard let value = value else {
                    failure?(.unknown)
                    return
                }
                guard let res = response.response, let statusCode = res.statusCode as? Int else {
                    failure?(.unknown)
                    return
                }
                if statusCode == 401 {
                    failure?(.apiError(message: NSLocalizedString("activity_txt542", comment: "서버에러")))
                    return
                }
                
                if statusCode == 404 {
                    failure?(.apiError(message: NSLocalizedString("activity_txt542", comment: "서버에러")))
                    return
                }
                
                if statusCode >= 500 && statusCode < 600 {
                    failure?(.apiError(message: NSLocalizedString("activity_txt543", comment: "서버연결에러")))
                    return
                }
                
                let json = JSON(value)
                let reuslt = json["Result"]
//                print("======= response =======")
//                debugPrint(json)
                if reuslt.isEmpty == false {
                    success?(reuslt)
                }
                else {
                    success?(json)
                }
                break
            case .failure :
                failure?(.unknown)
                break
            }
        }
    }
}
