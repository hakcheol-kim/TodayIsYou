//
//  BannerView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/06/14.
//

import UIKit
import SwiftyJSON
let ANI_TIMEINTERVAL = 3.0
class BannerView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var data = [JSON]()
    var completion: ((_ index: Int, _ item:JSON) -> Void)?
    var timer: Timer?
    var count: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func configuration(_ data: [JSON], completion: @escaping (_ index: Int, _ item:JSON) ->Void) {
        self.data = data
        self.completion = completion
        
        self.reloadData()
    }
    
    func reloadData() {
        count = data.count
        pageControl.numberOfPages = data.count
        scrollView.delegate = self
        for subview in svContent.subviews {
            subview.removeFromSuperview()
        }
        let width = UIScreen.main.bounds.width*0.84
        for i in 0..<(count+2) {
            var tmpIdx = 0
            if i == 0 {
                tmpIdx = count
            }
            else if i == count + 1 {
                tmpIdx = 1
            }
            else {
                tmpIdx = i
            }
            
            let index = tmpIdx-1
            
            let ivThumb = UIImageView.init()
            ivThumb.isUserInteractionEnabled = true
            ivThumb.tag = index
            ivThumb.clipsToBounds = true
            svContent.addArrangedSubview(ivThumb)
            ivThumb.translatesAutoresizingMaskIntoConstraints = false
            ivThumb.widthAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1).isActive = true
//            ivThumb.widthAnchor.constraint(equalToConstant: width).isActive = true
            
            ivThumb.contentMode = .scaleAspectFill
            
            let item = data[index]
//          "banner_url" : "\/app\/img\/210601_popup.jpg",
//          "banner_seq" : "1",
//          "banner_intent" : "http:\/\/todayisyou.co.kr\/event\/ev5\/ev5.html",
//          "banner_type" : "web"
            let banner_url = item["banner_url"].stringValue
            let url = baseUrl2+banner_url
            ivThumb.setImageCache(url)

            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
            ivThumb.addGestureRecognizer(tap)
        }
        
        addTimer()
    }
    @objc func tapGestureHandler(_ gesture: UIGestureRecognizer) {
        guard let completion = self.completion else {
            return
        }
        let tag = gesture.view?.tag ?? 0
        let item = data[tag]
        completion(tag, item)
    }
    
    func addTimer() {
        removeTimer()
        timer = Timer.scheduledTimer(timeInterval: ANI_TIMEINTERVAL, target: self, selector: #selector(nextImage), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    func removeTimer() {
        if let timer = timer {
            timer.invalidate()
            timer.fire()
        }
    }
    @objc func nextImage() {
        let currentPage = pageControl.currentPage
        scrollView.setContentOffset(
            CGPoint(x: CGFloat((currentPage + 2)) * scrollView.frame.size.width, y: 0),
            animated: true)
    }
    
    func handleDidScroll() {
//        if delegate.responds(to: #selector(bannerView(_:didScrollToIndex:))) {
//            delegate.bannerView(self, didScrollToIndex: pageControl.currentPage)
//        }
    }
}
extension BannerView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollW = self.scrollView.frame.size.width
        let currentPage = Int(self.scrollView.contentOffset.x / scrollW)

        if currentPage == count + 1 {
            pageControl.currentPage = 0
        } else if currentPage == 0 {
            pageControl.currentPage = count
        } else {
            pageControl.currentPage = currentPage - 1
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let scrollW = self.scrollView.frame.size.width
        let currentPage = Int(ceil(self.scrollView.contentOffset.x / scrollW))

        if currentPage == (count + 1) {
            pageControl.currentPage = 0
            self.scrollView.setContentOffset(CGPoint(x: scrollW, y: 0), animated: false)
        }
        else if currentPage == 0 {
            pageControl.currentPage = count
            self.scrollView.setContentOffset(CGPoint(x: count * Int(scrollW), y: 0), animated: false)
        } else {
            pageControl.currentPage = currentPage - 1
        }
//        handleDidScroll()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeTimer()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
    }
    
}
