//
//  PictureWkWebViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/18.
//

import UIKit
import WebKit
import SwiftyJSON
import CryptoKit

class PictureWkWebViewController: BaseViewController {
    var webView: WKWebView!
    var param: [String : Any]!
    var vcTitle: String!
    var didFinish:((_ result: Bool) ->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, vcTitle, #selector(onClickedBtnActions(_ :)))
        
        self.view.backgroundColor = .appColor(.whiteBg)
        self.view.layoutIfNeeded()
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "todayisyou")
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = WKProcessPool()
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        webConfiguration.userContentController = contentController
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.ignoresViewportScaleLimits = false
        
        if #available(iOS 14.0, *) {
            webConfiguration.limitsNavigationsToAppBoundDomains = true
            webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: webConfiguration)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.scrollView.bounces = true
        self.webView.scrollView.contentInset = .zero
        self.webView.allowsBackForwardNavigationGestures = true
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        
        var urlStr = PICTURE_REGIST_URL+"?"
        var index = 0
        for (key, value) in param {
            if index == 0 {
                urlStr.append("\(key)=\(value)")
            }
            else {
                urlStr.append("&\(key)=\(value)")
            }
            index += 1
        }
        guard let urlEncoding = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlEncoding) else {
            return
        }
            
        webView.backgroundColor = .appColor(.whiteBg)
        webView.cleanAllCookies {
            self.webView.refreshCookies()
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    @objc private func printCookie() {
        guard let url = webView.url else {
            return
        }
        
        print("=====================Cookies=====================")
        HTTPCookieStorage.shared.cookies(for: url)?.forEach {
            print($0)
        }
        print("=================================================")
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_BACK {
            self.didFinish?(false)
            if (self.navigationController != nil) {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension PictureWkWebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("userContentController")
        print("=== funcname: \(message.name)")
        print("=== data: \(message.body)")
        
        guard message.name == "todayisyou", let json = JSON(message.body) as? JSON else {
            return
        }
        
        let data = json["data"].dictionaryValue
        let type = json["type"].stringValue
        //pictureRegister 등록결과
        if type == "pictureRegister" {
            if data["code"] == "000" {
                appDelegate.window?.makeToast(NSLocalizedString("picture_regist_result_success", comment: ""))
                self.didFinish?(true)
                self.navigationController?.popViewController(animated: true)
            }
            else {
               self.showToast(NSLocalizedString("picture_regist_result_fail", comment: ""))
            }
        }
        else if type == "pictureEdit" {
            if data["code"] == "000" {
                appDelegate.window?.makeToast(NSLocalizedString("picture_modify_result_success", comment: ""))
                self.didFinish?(true)
                self.navigationController?.popViewController(animated: true)
            }
            else {
               self.showToast(NSLocalizedString("picture_modify_result_fail", comment: ""))
            }
        }
    }
}

extension PictureWkWebViewController: WKUIDelegate, WKNavigationDelegate {
    func interCeptUrl(_ url: URL?) -> Bool {
        guard let url = url else {
            return false
        }
        if url.path.contains("last_kcb") {
            print("====== last_kcb")
            return true
        }
        return false
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        print("=== navigationAction")
        print("=== \(navigationAction.request.url?.absoluteString ?? "")")
        decisionHandler(.allow, preferences)
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("=== didCommit")
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        print("=== didStartProvisionalNavigation")
    }
    
    func webView(webView: WKWebView, navigation: WKNavigation, withError error: NSError) {
        print("=== withError")
        print(error);
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("=== didReceiveServerRedirectForProvisionalNavigation")
        print("=== \(webView.url?.absoluteString ?? "")")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("=== didFail")
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("=== navigationResponse")
        print("\(webView.url?.absoluteString ?? "")")
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("=== didFinish")
        print("=== \(webView.url?.absoluteString ?? "")")
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        
        CAlertView.showWithOk(title: NSLocalizedString("activity_txt526", comment: "알림"), message: message) {[weak self] index in
            completionHandler()
        }
        print("=== runJavaScriptAlertPanelWithMessage:\(message)")
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        CAlertView.showWithCanCelOk(title: NSLocalizedString("activity_txt526", comment: "알림"), message: message) {[weak self] index in
            if index == 0 {
                completionHandler(false)
            }
            else {
                completionHandler(true)
            }
        }
        print("=== runJavaScriptConfirmPanelWithMessage:\(message)")
    }
}

