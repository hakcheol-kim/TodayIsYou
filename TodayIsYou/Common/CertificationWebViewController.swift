//
//  CertificationWebViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/22.
//

import UIKit
import WebKit
import SwiftyJSON


class CertificationWebViewController: BaseViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var btnBack: CButton!
    var mainUrl: URL!
    var webView: WKWebView!
    var didFinish:((_ result: Bool) ->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.webView = WKWebView(frame: baseView.bounds, configuration: webConfiguration)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.scrollView.bounces = false
        self.webView.scrollView.contentInset = .zero
        self.webView.allowsBackForwardNavigationGestures = true
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        baseView.addSubview(webView)
        webView.topAnchor.constraint(equalTo: self.baseView.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: self.baseView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.baseView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.baseView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        //"http://www.quizmall.co.kr/cms/kcb_ci/today_app_cnfrm_popup2.php?in_tp_bit=0&hs_cert_rqst_caus_cd=99&form_name=formKcb"
        
        guard let url = URL(string: KCB_CER_URL) else {
            return
        }
        mainUrl = url
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
        if sender == btnBack {
            self.didFinish?(false)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension CertificationWebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("userContentController")
        print("=== funcname: \(message.name)")
        print("=== data: \(message.body)")
        
        guard message.name == "todayisyou", let json = JSON(message.body) as? JSON else {
            return
        }
        
        let data = json["data"].dictionaryValue
        let type = json["type"].stringValue
        var message = data["message"]?.stringValue ?? ""
        let rslt_cd = data["RSLT_CD"]?.stringValue ?? ""
        
        if message.isEmpty == true {
            message = "본인 인증에 성공하였습니다."
        }
        if type == "cetification" {
            CAlertView.showWithOk(title: NSLocalizedString("activity_txt526", comment: "알림"), message: message) {[weak self] index in
                print("message: \(message), code: \(rslt_cd)")
                if rslt_cd == "B000" { //성공
                    ShareData.ins.dfsSet(true, DfsKey.check19Plus)
                    self?.didFinish?(true)
                }
                else {
                    self?.didFinish?(false)
                }
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension CertificationWebViewController: WKUIDelegate, WKNavigationDelegate {
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

