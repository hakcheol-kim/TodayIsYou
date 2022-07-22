//
//  UIImageView+Extension.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/22.
//

import Foundation
import UIKit
import AlamofireImage
import CoreGraphics
import SwiftyJSON

let imgDownloader = ImageDownloader()
//FIXME:: UIImageView
extension UIImageView {
    func setImageCache(_ url:String, _ placeholderImgName:String? = nil) {
        var placeholderImg: UIImage? = nil
        if let placeholderImgName = placeholderImgName {
            placeholderImg = UIImage(named: placeholderImgName)
        }
        
        guard let encodingUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let requestUrl = URL.init(string: encodingUrl) else {
            return
        }
        self.af.setImage(withURL: requestUrl, placeholderImage: placeholderImg)
    }
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
            contentMode = mode
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() { [weak self] in
                    self?.image = image
                }
            }.resume()
        }
        func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
            guard let url = URL(string: link) else { return }
            downloaded(from: url, contentMode: mode)
        }
}
