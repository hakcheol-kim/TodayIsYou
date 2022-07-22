//
//  CertificationSFSafariViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/29.
//

import UIKit
import SafariServices

class CertificationSFSafariViewController: SFSafariViewController {
    var url: String!
    var didFinish:((_ result: Bool) ->Void)?
    
    convenience init(_ url: String, didFinish:((_ result:Bool) ->Void)?) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        self.init(url: URL(string: url)!, configuration: config)
        self.didFinish = didFinish
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if let url = url {
            print(url)
        }
    }
    
}

extension CertificationSFSafariViewController: SFSafariViewControllerDelegate {
//    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
//
//    }
//    func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
//
//    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish")
    }
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("didCompleteInitialLoad")
    }
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        print("initialLoadDidRedirectTo: \(String(describing: URL.absoluteString.removingPercentEncoding))")
    }
    func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
        print("safariViewControllerWillOpenInBrowser")
    }
}

