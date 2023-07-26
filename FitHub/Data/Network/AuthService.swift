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
    
    func signInPhoneNumber(_ phoneNum: String, _ password: String)->Single<PhoneNumLoginDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/sign-in"
        let paramter: Parameters = ["targetPhoneNum" : phoneNum,
                                    "password" : password]
        return Single<PhoneNumLoginDTO>.create { observer in
            AF.request(urlString, method: .post, parameters: paramter, encoding: JSONEncoding.default)
                .responseDecodable(of: BaseResponse<PhoneNumLoginDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            observer(.success(result))
                        } else if response.code == 4019 {
                            observer(.failure(AuthError.unknownUser))
                        }
                    case .failure:
                        observer(.failure(AuthError.serverError))
                    }
                }
            return Disposables.create()
        }
    }
    
    func signUpWithPhoneNumber(_ registUserInfo: AuthUserInfo)-> Single<RegistResponseDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL) }
        let urlString = baseURL + "users/sign-up"
        let headers: HTTPHeaders = ["Content-Type" : "multipart/form-data"]

        let marketingAgree = registUserInfo.marketingAgree
        let preferExercises = registUserInfo.preferExercise.map { $0.id }
        guard let birth = registUserInfo.dateOfBirth,
              let gender = registUserInfo.sexNumber,
              let password = registUserInfo.password,
              let nicknae = registUserInfo.nickName,
              let name = registUserInfo.name,
              let phoneNumber = registUserInfo.phoneNumber,
              let profileImage = registUserInfo.profileImage?.pngData() else { return Single.error(AuthError.invalidURL) }
        
        let parameters: Parameters = ["birth" : birth,
                                      "gender" : gender,
                                      "marketingAgree" : marketingAgree,
                                      "password" : password,
                                      "nickname" : nicknae,
                                      "name" : name,
                                      "phoneNumber" : phoneNumber,
                                      "preferExercises" : preferExercises]
        
        return Single<RegistResponseDTO>.create { emitter in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(profileImage, withName: "profileImage")
                for (key,value) in parameters {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }, to: urlString, method: .post, headers: headers)
            .responseDecodable(of: BaseResponse<RegistResponseDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if let result = response.result {
                        emitter(.success(result))
                    } else {
                        emitter(.failure(AuthError.serverError))
                    }
                case .failure(let error):
                    emitter(.failure(error))
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
    
    //MARK: - 핸드폰 인증번호
    func checkUserInfo(_ phoneNum: String) -> Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/password"
        let parameter: Parameters = ["targetPhoneNum" : phoneNum]
        
        return Single<Int>.create { emitter in
            AF.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default)
                .responseDecodable(of: BaseResponse<Int>.self) { res in
                    switch res.result {
                    case .success(let response):
                        emitter(.success(response.code))
                    case .failure(_):
                        emitter(.failure(AuthError.invalidURL))
                    }
                }
            return Disposables.create()
        }
    }
    
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/sms"
        let parameter: Parameters = ["targetPhoneNum" : phoneNum]
        
        return Single<Int>.create { emitter in
            AF.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default)
                .responseDecodable(of: BaseResponse<Int>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if let code = response.result {
                            emitter(.success(code))
                        } else {
                            emitter(.failure(AuthError.invalidURL))
                        }
                    case .failure(_):
                        emitter(.failure(AuthError.invalidURL))
                    }
                }
            return Disposables.create()
        }
    }
    
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/sms/auth"
        let parameter: Parameters = ["phoneNum" : phoneNum,
                                     "authNum" : authNum]
        
        return Single<Int>.create { emitter in
            AF.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default)
                .responseDecodable(of:BaseResponse<PhoneAuthNumberDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        emitter(.success(response.code))
                    case .failure(let error):
                        print(error)
                    }
                }
            return Disposables.create()
        }
    }
    
    //MARK: - 카테고리
    func fetchCategory() -> Single<[CategoryDTO]> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/exercise-category"
        
        return Single<[CategoryDTO]>.create { emitter in
            AF.request(urlString)
                .responseDecodable(of: BaseArrayResponse<CategoryDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        guard let result = response.result else { return }
                        emitter(.success(result))
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
}
