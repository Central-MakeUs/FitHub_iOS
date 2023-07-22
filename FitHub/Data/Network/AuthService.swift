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
    //MARK: - Login
    func signInAppleLogin(_ token: String)->Single<OAuthLoginDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/login/social/apple"
        let paramter: Parameters = ["identityToken" : token]
        
        return Single<OAuthLoginDTO>.create { observer in
            AF.request(urlString, method: .post, parameters: paramter, encoding: JSONEncoding.default)
                .responseDecodable(of: BaseResponse<OAuthLoginDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2006 || response.code == 2007 {
                            guard let result = response.result else { return }
                            observer(.success(result))
                        } else {
                            observer(.failure(AuthError.serverError))
                        }
                    case .failure:
                        observer(.failure(AuthError.serverError))
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
                .responseDecodable(of: BaseResponse<OAuthLoginDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2004 || response.code == 2005 {
                            guard let result = response.result else { return }
                            observer(.success(result))
                        } else {
                            observer(.failure(AuthError.serverError))
                        }
                    case .failure:
                        observer(.failure(AuthError.serverError))
                    }
                }
            return Disposables.create()
        }
    }
    
    func signInPhoneNumber(_ phoneNum: String, _ password: String)->Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/sign-in"
        let paramter: Parameters = ["targetPhoneNum" : phoneNum,
                                    "password" : password]
        return Single<Int>.create { observer in
            AF.request(urlString, method: .post, parameters: paramter, encoding: JSONEncoding.default)
                .responseDecodable(of: BaseResponse<PhoneNumLoginDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            observer(.success(response.code))
                        } else {
                            observer(.failure(AuthError.serverError))
                        }
                    case .failure(let error):
                        if res.response?.statusCode == 400 {
                            observer(.failure(AuthError.unknownUser))
                        } else {
                            observer(.failure(AuthError.serverError))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    
    //MARK: - 닉네임 중복 체크
    func duplicationNickNameCheck(_ nickName: String) -> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/exist-nickname"
        let paramter: Parameters = ["nickname" : nickName]
        
        return Single<Bool>.create { observer in
            AF.request(urlString, parameters: paramter, encoding: URLEncoding.queryString)
                .responseDecodable(of: BaseResponse<String>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2010 {
                            observer(.success(true))
                        } else if response.code == 2011 {
                            observer(.success(false))
                        } else {
                            observer(.failure(AuthError.serverError))
                        }
                    case .failure:
                        observer(.failure(AuthError.serverError))
                    }
                }
            return Disposables.create()
        }
    }
}
