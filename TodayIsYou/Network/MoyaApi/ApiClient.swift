//
//  CommonProvider.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/02/24.
//

import Foundation
import Moya
import Combine
import SwiftyJSON

public enum API {
    case upload(gif: Data)
    case fetchPictorialList(category: Int, current_page: Int, page_cnt: Int)
    case adultCheck
    case checkSelfAuth(user_id: String)
    case updateSelfAuth(user_id: String)
    case pictureDetail(seq: String, bpUserId: String)
    case fetchRankList(user_id: String)
    case fetchPictureAlbumList(param:[String:Any])
    case purchasePicture(_ param: [String:Any])
    case fetchMyPictureList(_ param: [String:Any])
    case purchasedPictureList(_ param: [String:Any])
    case pictureEarningList(_ param: [String : Any])
    case deletePicture(userId: String, seq:String)
    case sendRandomMessage(_ param: [String:Any])
    case underReviewIos   
}

extension API: TargetType {
    
    public var baseURL: URL {
        URL(string: "https://api3.todayisyou.co.kr")!
    }
    
    public var path: String {
        switch self {
        case .upload:
            return ""
        case .fetchPictorialList:
            return "/app/bb/bb_list.php"
        case .adultCheck:
            return "/app/kcb_ci/adult_check.php"
        case .checkSelfAuth:
            return "/app/bb/bb_sa_yn.php"
        case .updateSelfAuth:
            return "app/bb/bb_sa_ud.php"
        case .pictureDetail:
            return "app/bb/bb_view.php"
        case .fetchRankList:
            return "app/bb/bb_rank.php"
        case .fetchPictureAlbumList:    //타인 앨범 보기
            return "app/bb/bb_md_list.php"
        case .purchasePicture:
            return "app/bb/bb_pic_oi.php"
        case .fetchMyPictureList:   //내 화보 리스트
            return "app/bb/bb_my_pic.php"
        case .purchasedPictureList: //구매한 포토 리스트
            return "app/bb/bb_ol_list.php"
        case .pictureEarningList:   //화보 수익금 리스트
            return "app/bb/bb_my_rcp.php"
        case .deletePicture:    //화보 삭제
            return "app/bb/bb_delete.php"
        case .sendRandomMessage:        //랜덤 쪽지
            return "app/mlt/message_act.php"
        case .underReviewIos:
            return "app/list/listtype_ios.php"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .upload,
                .adultCheck,
                .fetchPictorialList,
                .pictureDetail,
                .fetchRankList,
                .fetchPictureAlbumList,
                .purchasePicture,
                .fetchMyPictureList,
                .purchasedPictureList,
                .pictureEarningList,
                .deletePicture,
                .sendRandomMessage:
            return .post
        case .checkSelfAuth, .updateSelfAuth, .underReviewIos:
            return .get
        }
    }
    public var headers: [String : String]? {
        var headers: [String : String] = [
            "Content-Type": "application/json;charset=UTF-8",
            "Accept": "application/json"
        ]
        let languageCode = ShareData.ins.serverLanguageCode.uppercased()
        headers["forgn_lang"] = languageCode
        headers["app_type"] = appType
        
        return headers
    }
    public var parameterEncoding: URLEncoding {
        switch self {
        case .adultCheck,
                .checkSelfAuth,
                .updateSelfAuth,
                .fetchPictorialList,
                .pictureDetail,
                .fetchRankList,
                .fetchPictureAlbumList,
                .purchasePicture,
                .fetchMyPictureList,
                .purchasedPictureList,
                .pictureEarningList,
                .deletePicture,
                .sendRandomMessage,
                .underReviewIos:
            
            return URLEncoding.queryString
        case .upload:
            return URLEncoding.httpBody
        }
    }
    public var task: Task {
        switch self {
        case .adultCheck, .underReviewIos:
//            return .requestPlain
            let param: [String: Any] = ["app_type": appType]
            return .requestParameters(parameters: param, encoding: self.parameterEncoding)
        case let .fetchPictorialList(category, current_page, page_cnt):
            let param: [String : Any] = ["user_id":ShareData.ins.myId, "category":category, "current_page":current_page, "page_cnt":page_cnt]
            return .requestParameters(parameters:param, encoding: self.parameterEncoding)
        case let .checkSelfAuth(user_id), let .updateSelfAuth(user_id), let .fetchRankList(user_id):
            let param: [String: Any] = ["user_id": user_id]
            return .requestParameters(parameters: param, encoding: self.parameterEncoding)
        case let .pictureDetail(seq, bpUserId):
            let param:[String : Any] = ["user_id": ShareData.ins.myId, "seq" : seq, "bp_user_id" : bpUserId]
            return .requestParameters(parameters: param, encoding: self.parameterEncoding)
        case let .deletePicture(userId, seq):
            let param:[String : Any] = ["user_id": userId, "seq" : seq]
            return .requestParameters(parameters: param, encoding: self.parameterEncoding)
        case let .fetchPictureAlbumList(param),
            let .purchasePicture(param),
            let .fetchMyPictureList(param),
            let .purchasedPictureList(param),
            let .pictureEarningList(param),
            let .sendRandomMessage(param):
            return .requestParameters(parameters: param, encoding: self.parameterEncoding)
        case let .upload(data):
            let multipartFormData = [MultipartFormData(provider: .data(data), name: "file", fileName: "gif.gif", mimeType: "image/gif")]
            return .uploadCompositeMultipart(multipartFormData, urlParameters: ["api_key": "dc6zaTOxFJmzC", "username": "Moya"])
        }
    }
    public var validationType: ValidationType {
        return .successCodes
    }
}
extension Moya.Response {
    func mapCustomModle<T: Decodable>() throws -> T {
        do {
            let model = try self.map(T.self)
            return model
        }
        catch {
            throw CError.parserError(message: "Data Decodable Error")
        }
    }
}
extension MoyaError {
    func convertMyError() -> CError {
        switch self {
        case .imageMapping, .jsonMapping, .stringMapping, .objectMapping, .encodableMapping:
            return CError.parserError(message: NSLocalizedString("DataPasing error", comment: ""))
        case .statusCode:
            return CError.apiError(message: NSLocalizedString("State code", comment: ""))
        case .underlying(let error, _):
            guard let error = error as? URLError else {
                return CError.customError(message: "Error")
            }
            return CError.networkError(form: error)
        case .requestMapping:
            return CError.apiError(message: "Failed to map Endpoint to a URLRequest.")
        case .parameterEncoding(let error):
            return CError.apiError(message: "Failed to encode parameters for URLRequest. \(error.localizedDescription)")
        }
    }
}


//let apiProvider: MoyaProvider<ApiClient> = MoyaProvider<API>(plugins: [NetworkLoggerPlugin(configuration:.init(logOptions: .verbose))])
//let apiProvider: MoyaProvider<API> = MoyaProvider<API>()
class ApiClient {
    static let ins = ApiClient()
//    private let provider: MoyaProvider<API> = MoyaProvider<API>()

//    private let provider: MoyaProvider<API> = MoyaProvider<API>(plugins: [NetworkLoggerPlugin(configuration:.init(logOptions: .successResponseBody))])
    
    private let provider = MoyaProvider<API>(plugins: [VerbosePlugin(verbose: true)])
    
    func request<D: Decodable>(_ target: API, _ type: D.Type, success:@escaping(_ result:D) ->Void, failure: @escaping(_ error: CError?)->Void) {
        appDelegate.startIndicator()
        provider.request(target) { result in
            appDelegate.stopIndicator()
        
            switch result {
            case .success(let value):
                do {
                    let model = try value.map(type.self)
                    success(model)
                }
                catch let error {
                    failure(error as? CError)
                }
                return
            case .failure(let error):
                let myError = error.convertMyError()
                failure(myError)
                return
            }
        }
    }
    
    func requestJSON(_ target: API, success:@escaping(_ result:JSON) ->Void, failure: @escaping(_ error: CError?)->Void) {
        appDelegate.startIndicator()
        
        provider.request(target) { result in
            appDelegate.stopIndicator()
            switch result {
            case .success(let value):
                do {
                    let model = try JSON(data: value.data)
                    success(model)
                } catch {
                    failure(CError.parserError(message: "Json parser error"))
                }
                return
            case .failure(let error):
                let myError = error.convertMyError()
                failure(myError)
                return
            }
        }
    }
}
struct VerbosePlugin: PluginType {
    let verbose: Bool
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if verbose {
            if let url = request.url?.absoluteString {
                print("=== url: \(url)")
            }
            if let body = request.httpBody, let str = String(data: body, encoding: .utf8) {
                print("=== param: \(str)")
            }
        }
        return request
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if (verbose) {
            switch result {
            case .success(let response):
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: .mutableContainers) {
                    print("response: \(json)")
                } else {
                    let response = String(data: response.data, encoding: .utf8)!
                    print("response: \(response)")
                }
            case .failure(let error):
                if let errorDes = error.errorDescription {
                    print("ERROR: 🥵 \(errorDes)")
                }
            }
        }
    }
}
