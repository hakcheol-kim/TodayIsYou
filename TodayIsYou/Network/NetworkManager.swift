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
typealias ResFailure = (Any) -> Void

enum AppError: String, Error {
    case invalidResponseType = "response data type not dictionary"
    case reqeustStatusCodeOverRage = "response status code over range 200 ~ 300"
}

enum ContentType: String {
    case json = "application/json; charset=utf-8"
    case formdata = "multipart/form-data"
    case urlencoded = "application/x-www-form-urlencoded"
    case text = "text/plain"
}

class NetworkManager: NSObject {
    static let ins = NetworkManager()
    
    func getFullUrl(_ url:String) -> String {
        return "\(baseUrl)\(url)"
    }
    
    func request(_ method: HTTPMethod, _ url: String, _ param:[String:Any]?, _ encoding:ParameterEncoding = JSONEncoding.default, success:ResSuccess?, failure:ResFailure?) {
        let fullUrl = self.getFullUrl(url)
        
        guard let encodedUrl = fullUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        AppDelegate.ins.startIndicator()
        let header: HTTPHeaders = [.contentType(ContentType.json.rawValue), .accept(ContentType.json.rawValue)]
        
        let request = AF.request(encodedUrl, method: method, parameters: param, encoding: encoding, headers: header)
        request.responseJSON { (response:AFDataResponse<Any>) in
            if let url = response.request?.url?.absoluteString {
                print("\n=======request: url: \(String(describing: url))")
                if let param = param {
                    print(String(describing: param))
                }
            }
            print("\n======= response ======= \n\(response)")
            AppDelegate.ins.stopIndicator()
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                success?(json["Result"])
                break
            case .failure(let error):
                failure?(error)
                break
            }
        }
    }
}
