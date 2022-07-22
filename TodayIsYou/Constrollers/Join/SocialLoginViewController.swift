//
//  SocialLoginViewController.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/23.
//

import UIKit

import Firebase
import FirebaseAuth
//import FBSDKLoginKit    //face book
//import NaverThirdPartyLogin //naver login
//import KakaoSDKCommon   //kakao
//import KakaoSDKAuth
//import KakaoSDKUser
//import GoogleSignIn //google

import AuthenticationServices   //apple

import CryptoSwift
import Alamofire
import SwiftyJSON

enum LoginType {
    case kakao, facebook, apple, naver, google
}

class SocialLoginViewController: BaseViewController {
    var user:[String:Any] = [:]
    var currentNonce: String? = nil
    
    var completion:((_ user:[String:Any]?, _ error: Error?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loginWithType(_ type: LoginType, _ completion:((_ user:[String:Any]?, _ error: Error?) -> Void)?) {
        self.completion = completion
        
        if type == .kakao {
//            self.loginKako()
        }
        else if type == .naver {
//            self.loginNaver()
        }
        else if type == .facebook {
//            self.loginFacebook()
        }
        else if type == .apple {
            self.loginApple()
        }
//        else if type == .google {
//            GIDSignIn.sharedInstance()?.delegate = self
//            GIDSignIn.sharedInstance()?.presentingViewController = self
//            GIDSignIn.sharedInstance().signIn()
//        }
        else {
            self.completion?(nil, nil)
        }
    }
    
    /// kakao
    /*private func loginKako() {
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
        connection?.requestThirdPartyLogin()
    }
    
    private func getNaverInfo() {
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        guard let isValidAccessToken = instance?.isValidAccessTokenExpireTimeNow() else { return }
        
        if !isValidAccessToken {
            return
        }
        
        guard let tokenType = instance?.tokenType else { return }
        guard let accessToken = instance?.accessToken else { return }
        
        let urlStr = "https://openapi.naver.com/v1/nid/me"
        let url = URL(string: urlStr)!
        
        let authorization = "\(tokenType) \(accessToken)"
        
        let req = AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": authorization])
        
        req.responseJSON { response in
            switch response.result {
            case .success(let value):
                guard let value = value as? [String:Any], let object = value["response"] else {
                    self.completion?(nil, nil)
                    return
                }
                
                let json = JSON(object)
                
                self.user["joinType"] = "naver"
                self.user["accessToken"] = json["access_token"].stringValue
                self.user["userId"] = json["id"].stringValue
                
                let email = json["email"].stringValue
                let name = json["name"].stringValue
                let nickname = json["nickname"].stringValue
                let profile_image = json["profile_image"].stringValue
                let birthday = json["birthday"].stringValue
                let gender = json["gender"].stringValue
                
                if email.isEmpty == false {
                    self.user["email"] = email
                }
                if name.isEmpty == false {
                    self.user["name"] = name
                }
                if nickname.isEmpty == false {
                    self.user["nickname"] = nickname
                }
                if profile_image.isEmpty == false {
                    self.user["profileImageUrl"] = profile_image
                }
                if birthday.isEmpty == false {
                    self.user["birthday"] = birthday
                }
                if gender.isEmpty == false {
                    self.user["gender"] = gender
                }
                print("=== naver login: \(self.user)")
                self.completion?(self.user, nil)
                
                break
            case .failure(let error):
                self.completion?(nil, error)
                break
            }
        }
    }
    /// facebook
    private func loginFacebook() {
        if let token = AccessToken.current, !token.isExpired {
            self.user["accessToken"] = token
            self.fetchFacebookMe()
        }
        else {
            let loginManager = LoginManager()
            let readPermission:[Permission] = [.publicProfile]
            loginManager.logIn(permissions: readPermission, viewController: self) { (result: LoginResult) in
                switch result {
                case .success(granted: _, declined: _, token: _):
                    self.signInFirebase()
                case .cancelled:
                    print("facebook login cancel")
                    self.completion?(nil, nil);
                case .failed(let err):
                    print(err)
                    self.completion?(nil, err);
                }
            }
        }
    }
    
    func fetchFacebookMe() {
        let connection = GraphRequestConnection()
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: .get)
        
        connection.add(request) { (httpResponse, result, error: Error?) in
            if nil != error {
                print(error!)
                self.completion?(nil, nil)
                return
            }
            guard let result = result else {
                self.completion?(nil, nil)
                return
            }
            
            if let dic:Dictionary = result as? Dictionary<String, AnyObject>, let id = dic["id"] {
                self.user["userId"] = "\(id)"
                self.user["joinType"] = "facebook"
                self.completion?(self.user, nil)
            }
        }
        connection.start()
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
    func signInFirebase() {
        guard let token = AccessToken.current?.tokenString else {
            return
        }
        
        self.user["accessToken"] = token
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential) { (user: AuthDataResult?, error: Error?) in
            if let error = error {
                print(error)
            }
            else {
                self.fetchFacebookMe()
            }
        }
    }
 */
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
/*
/// 네이버 로그인
extension SocialLoginViewController: NaverThirdPartyLoginConnectionDelegate {
    // 로그인 버튼을 눌렀을 경우 열게 될 브라우저
//    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
//        let naverSignInVC = NLoginThirdPartyOAuth20InAppBrowserViewController(request: request)!
//        naverSignInVC.parentOrientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
//        present(naverSignInVC, animated: false, completion: nil)
//    }
    
    // 로그인에 성공했을 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("[Success] : Success Naver Login")
        self.getNaverInfo()
    }
    
    // 접근 토큰 갱신
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.requestDeleteToken()
    }
    
    // 로그아웃 할 경우 호출(토큰 삭제)
    func oauth20ConnectionDidFinishDeleteToken() {
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.requestDeleteToken()
    }
    
    // 모든 Error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] :", error.localizedDescription)
    }
}
*/

///애플 로그인
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

