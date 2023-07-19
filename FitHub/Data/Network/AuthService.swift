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
    func signInAppleLogin(_ token: String)->Single<OAuthLoginDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/login/social/apple"
        let paramter: Parameters = ["identityToken" : token]
        
        return Single<OAuthLoginDTO>.create { observer in
            AF.request(urlString, method: .post, parameters: paramter, encoding: JSONEncoding.default)
                .responseDecodable(of: OAuthLoginDTO.self){ res in
                    switch res.result {
                    case .success(let data):
                        observer(.success(data))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func signInKakaoLogin(_ socialId: String)->Single<OAuthLoginDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/login/social/kakao"
        let paramter: Parameters = ["socialId" : socialId]
        return Single<OAuthLoginDTO>.create { observer in
            AF.request(urlString, method: .post, parameters: paramter, encoding: JSONEncoding.default)
                .responseDecodable(of: OAuthLoginDTO.self) { res in
                    switch res.result {
                    case .success(let data):
                        observer(.success(data))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func duplicationNickNameCheck(_ nickName: String) -> Single<NickNameDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/exist-nickname"
        let paramter: Parameters = ["nickname" : nickName]
        
        return Single<NickNameDTO>.create { observer in
            AF.request(urlString, parameters: paramter, encoding: URLEncoding.queryString)
                .responseDecodable(of: NickNameDTO.self) { res in
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
