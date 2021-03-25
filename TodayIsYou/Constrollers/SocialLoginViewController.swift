//
//  SocialLoginViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/23.
//

import UIKit

import Firebase
import FirebaseAuth
import FBSDKLoginKit

import NaverThirdPartyLogin

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

import AuthenticationServices
import CryptoSwift

enum LoginType {
    case kakao, facebook, apple, naver
}

class SocialLoginViewController: UIViewController {
    var user:[String:Any] = [:]
    var currentNonce: String? = nil
    
    var completion:((_ user:[String:Any]?, _ error: Error?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loginWithType(_ type: LoginType, _ completion:((_ user:[String:Any]?, _ error: Error?) -> Void)?) {
        self.completion = completion
     
        if type == .kakao {
            self.loginKako()
        }
        else if type == .naver {
            self.loginNaver()
        }
        else if type == .facebook {
            self.loginFacebook()
        }
        else if type == .apple {
            self.loginApple()
        }
        else {
            self.completion?(nil, nil)
        }
    }
    
    /// kakao
    private func loginKako() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    self.completion?(nil, error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    self.user["token"] = oauthToken?.accessToken ?? ""
                    self.user["expiresIn"] = oauthToken?.expiresIn ?? ""
                    self.user["expiredAt"] = oauthToken?.expiredAt ?? ""
                    self.user["refreshToken"] = oauthToken?.refreshToken ?? ""
                    
                    UserApi.shared.me { (user, error) in
                        
                        if let error = error {
                            self.completion?(nil, error)
                            return
                        }
                        
                        guard let user = user else {
                            self.completion?(nil, error)
                            return
                        }
                        
                        self.user["joinType"] = "kakao"
                        self.user["userId"] = "\(user.id)"
                         
                        if let email = user.kakaoAccount?.email {
                            self.user["email"] = email
                        }
                        if let profileImageUrl:URL = user.kakaoAccount?.profile?.profileImageUrl {
                            self.user["profileImageUrl"] = profileImageUrl.absoluteString
                        }
                        if let nickname = user.kakaoAccount?.profile?.nickname {
                            self.user["nickname"] = nickname
                            self.user["name"] = nickname
                        }
                        if let birthday = user.kakaoAccount?.birthday {
                            self.user["birthday"] = birthday
                        }
                        if let gender = user.kakaoAccount?.gender?.rawValue {
                            self.user["gender"] = gender
                        }
                        self.completion?(self.user, nil)
                    }
                }
            }
        }
    }
    
    /// naver
    private func loginNaver() {
        let connection = NaverThirdPartyLoginConnection.getSharedInstance()
        connection?.delegate = self
        if let valid = connection?.isValidAccessTokenExpireTimeNow(), valid == false {
            connection?.requestThirdPartyLogin()
        }
        else {
            connection?.requestAccessTokenWithRefreshToken()
        }
    }
    
    private func reqeustFetchNaverUserInfo() {
        guard let naverConnection = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
        guard let accessToken = naverConnection.accessToken else { return }
        let authorization = "Bearer \(accessToken)"
        
        if let url = URL(string: "https://openapi.naver.com/v1/nid/me") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    self.completion?(nil, error)
                    return
                }
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                        self.completion?(nil, error)
                        return
                    }
                    guard let response = json["response"] as? [String: Any] else {
                        self.completion?(nil, error)
                        return
                    }
                    self.user["joinType"] = "naver"
                    self.user["accessToken"] = response["access_token"] ?? ""
                    self.user["userId"] = response["id"] ?? ""
                    
                    if let email = response["email"]  as?String {
                        self.user["email"] = email
                    }
                    
                    if let name = response["name"]  as?String {
                        self.user["name"] = name
                    }
                    if let nickname = response["nickname"]  as?String {
                        self.user["nickname"] = nickname
                    }
                    if let profileImageUrl = response["profile_image"]  as?String {
                        self.user["profileImageUrl"] = profileImageUrl
                    }
                    if let birthday = response["birthday"] as? String {
                        self.user["birthday"] = birthday
                    }
                    if let gender = response["gender"] as? String {
                        self.user["gender"] = gender
                    }
                    
                    DispatchQueue.main.async { [self] in
                        print("=== naver login: \(self.user)")
                        self.completion?(self.user, error)
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.completion?(nil, error)
                    }
                }
            }.resume()
        }
    }
    
    /// facebook
    private func loginFacebook() {
        let readPermission:[Permission] = [.publicProfile]
        LoginManager.init().logIn(permissions: readPermission, viewController: self) { (result) in
            switch result {
            case .success(granted: _ , declined: _ , token: _):
                guard let token = AccessToken.current?.tokenString else {
                    self.completion?(self.user, nil)
                    return
                }
                self.user["accessToken"] = token
                let credential = FacebookAuthProvider.credential(withAccessToken: token)
                Auth.auth().signIn(with: credential) { (user: AuthDataResult?, error: Error?) in
                    if let error = error {
                        self.completion?(self.user, error)
                    }
                    else {
                        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: .get)
                        let connection = GraphRequestConnection.init()
                        connection.add(request) { (httpResponse, result, error) in
                            if let dic:Dictionary = result as? Dictionary<String, AnyObject>, let id = dic["id"] {
                                self.user["userId"] = "\(id)"
                                self.user["joinType"] = "facebook"
                                self.completion?(self.user, nil)
                            }
                        }
                        connection.start()
                    }
                }
                break
            case .cancelled:
                self.completion?(nil, nil)
                break
            case .failed(let error):
                self.completion?(nil, error)
                break
            }
        }
    }
    private func faceBookLogOut(completion: @escaping (_ error: Error?) -> Void) {
        let loginManager = LoginManager()
        loginManager.logOut()
        let auth = Auth.auth()
        do {
            try auth.signOut()
            print("fb logout success")
            completion(nil)
        } catch let error {
            print("fb logout error")
            completion(error)
        }
    }
    
    /// apple
    private func loginApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
//    func performExistingAccountSetupFlows() {
//      // Prepare requests for both Apple ID and password providers.
//      let requests = [ASAuthorizationAppleIDProvider().createRequest(),
//                      ASAuthorizationPasswordProvider().createRequest()]
//
//      // Create an authorization controller with the given requests.
//      let authorizationController = ASAuthorizationController(authorizationRequests: requests)
//      authorizationController.delegate = self
//      authorizationController.presentationContextProvider = self
//      authorizationController.performRequests()
//    }
}

extension SocialLoginViewController: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        // 로그인 성공 (로그인된 상태에서 requestThirdPartyLogin()를 호출하면 이 메서드는 불리지 않는다.)
        self.reqeustFetchNaverUserInfo()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        // 로그인된 상태(로그아웃이나 연동해제 하지않은 상태)에서 로그인 재시도
        self.reqeustFetchNaverUserInfo()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
         // 연동해제 콜백
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
         //  접근 토큰, 갱신 토큰, 연동 해제등이 실패
    }
    
}
extension SocialLoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (self.view.window)!
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            
            self.user["joinType"] = "apple"
            self.user["userId"] = userIdentifier
            if let fullName = appleIDCredential.fullName {
                self.user["name"] = fullName
            }
            if let email = appleIDCredential.email {
                self.user["email"] = email
            }
            self.completion?(self.user, nil)
        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            let password = passwordCredential.password
            DispatchQueue.main.async {
                self.user["name"] = username
                self.user["password"] = password
                self.completion?(self.user, nil)
            }
            
        default:
            self.completion?(nil, nil)
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.completion?(nil, error)
        print(error)
    }
}
