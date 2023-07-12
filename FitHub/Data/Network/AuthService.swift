//
//  AuthService.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import Foundation
import Alamofire
import RxSwift

class AuthService {
    func signInAppleLogin(_ token: String)->Single<String> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/login/social/apple"
        let paramter: Parameters = ["identityToken" : token]
        
        return Single<String>.create { observer in
            AF.request(urlString, method: .post, parameters: paramter, encoding: JSONEncoding.default)
                .responseString(completionHandler: { res in
                    switch res.result {
                    case .success(let str):
                        observer(.success(str))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                })
            return Disposables.create()
        }
    }
    
    func duplicationNickNameCheck(_ nickName: String) -> Single<DefaultResponseModel> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/exist-nickname"
        let paramter: Parameters = ["nickname" : nickName]
        
        return Single<DefaultResponseModel>.create { observer in
            AF.request(urlString, parameters: paramter, encoding: URLEncoding.queryString)
                .responseDecodable(of: DefaultResponseModel.self) { res in
                    switch res.result {
                    case .success(let response):
                        observer(.success(response))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
