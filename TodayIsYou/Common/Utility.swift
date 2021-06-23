//
//  Utility.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/10.
//

import UIKit
import CryptoSwift
import Photos

class Utility: NSObject {
    class func isEdgePhone() -> Bool {
        return ((appDelegate.window?.safeAreaInsets.bottom)! > 0.0)
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
    
    class func getThumnailImage(with asset:PHAsset, _ completion:@escaping(_ image:UIImage?) -> Void) {
        var imageRequestOptions: PHImageRequestOptions {
               let options = PHImageRequestOptions()
               options.version = .current
               options.resizeMode = .exact
               options.deliveryMode = .highQualityFormat
               options.isNetworkAccessAllowed = true
               options.isSynchronous = true
               return options
           }
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 400, height: 400), contentMode:.aspectFit, options: imageRequestOptions) { (image, _)  in
            guard let image = image else {
                completion(nil)
                return
            }
            return completion(image)
        }
    }
    class func downloadImage(_ url:String, _ userInfo:[String:Any]? = nil, _ completion:@escaping(_ image:UIImage?, _ userInfo:[String:Any]?)->Void) {
        guard let uurl =  URL(string: url) else {
            completion(nil, userInfo)
            return
        }
        
        let request = URLRequest(url:uurl)
        imgDownloader.download(request, completion:  { response in
            if case .success(let image) = response.result {
                completion(image, userInfo)
            }
            else {
                completion(nil, userInfo)
            }
        })
    }
    class func randomSms5digit() -> String {
        let number = Int.random(in: 10000..<100000)
        return String(format: "%0ld", number)
    }
    class func roomKeyCam() -> String {
        let date = Utility.getCurrentDate(format: "yyyyMMddHHmmss")
        let random = Int.random(in: 0..<50)
        return "CAM_\(date)_\(random)"
    }
    class func roomKeyPhone() -> String {
        let date = Utility.getCurrentDate(format: "yyyyMMddHHmmss")
        let random = Int.random(in: 0..<50)
        return "PHONE_\(date)_\(random)"
    }
}
