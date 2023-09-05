//
//  AuthService.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import UIKit
import Alamofire
import RxSwift

class UserService {
    //MARK: - Login
    func signInAppleLogin(_ token: String, name: String)->Single<OAuthLoginDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let fcmToken = UserDefaults.standard.object(forKey: "fcmToken") as? String ?? ""
        let urlString = baseURL + "users/login/social/apple"
        var parameter: Parameters = ["identityToken" : token,
                                    "fcmToken" : fcmToken]
        if !name.isEmpty { parameter["userName"] = name }
        
        return Single<OAuthLoginDTO>.create { observer in
            AF.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default)
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
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL) }
        let fcmToken = UserDefaults.standard.object(forKey: "fcmToken") as? String ?? ""
        let urlString = baseURL + "users/login/social/kakao"
        let paramter: Parameters = ["socialId" : socialId,
                                    "fcmToken" : fcmToken]
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
        let fcmToken = UserDefaults.standard.object(forKey: "fcmToken") as? String ?? ""
        let urlString = baseURL + "users/sign-in"
        let parameter: Parameters = ["targetPhoneNum" : phoneNum,
                                     "password" : password,
                                     "fcmToken" : fcmToken]
        
        return Single<PhoneNumLoginDTO>.create { observer in
            AF.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default)
                .responseDecodable(of: BaseResponse<PhoneNumLoginDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            observer(.success(result))
                        } else if response.code == 4019 {
                            observer(.failure(AuthError.unknownUser))
                        } else if response.code == 4020 {
                            observer(.failure(AuthError.passwordFaild))
                        }
                    case .failure:
                        observer(.failure(AuthError.serverError))
                    }
                }
            return Disposables.create()
        }
    }
    
    //MARK: 회원가입
    func signUpWithPhoneNumber(_ registUserInfo: AuthUserInfo)-> Single<RegistResponseDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL) }
        let urlString = baseURL + "users/sign-up"
        let headers: HTTPHeaders = ["Content-Type" : "multipart/form-data"]
        let fcmToken = UserDefaults.standard.object(forKey: "fcmToken") as? String ?? ""
        let marketingAgree = registUserInfo.marketingAgree
        let preferExercises = registUserInfo.preferExercise.map { $0.id }
        guard let birth = registUserInfo.dateOfBirth,
              let gender = registUserInfo.sexNumber,
              let password = registUserInfo.password,
              let nickname = registUserInfo.nickName,
              let name = registUserInfo.name,
              let phoneNumber = registUserInfo.phoneNumber else { return Single.error(AuthError.invalidURL) }
        let profileImage = registUserInfo.profileImage?.pngData()
        
        let parameters: Parameters = [
            "gender" : gender,
            "marketingAgree" : marketingAgree,
            "birth" : birth,
            "name" : name,
            "nickname" : nickname,
            "phoneNumber" : phoneNumber,
            "password" : password,
            "fcmToken" : fcmToken]
        
        return Single<RegistResponseDTO>.create { emitter in
            AF.upload(multipartFormData: { multipartFormData in
                if let profileImage {
                    multipartFormData.append(profileImage, withName: "profileImage", fileName: "\(profileImage).png", mimeType: "image/png")
                }
                
                let preferExercises = preferExercises.map { String($0) }.joined(separator: ",")
                multipartFormData.append(preferExercises.data(using: .utf8)!, withName: "preferExercises")
                
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
    
    //MARK: - 소셜 회원가입
    func signUpWithOAuth(_ registUserInfo: AuthUserInfo)-> Single<RegistResponseDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL) }
        let urlString = baseURL + "users/sign-up/oauth"
        guard let accessToken = KeychainManager.read("accessToken") else { return Single.error(AuthError.invalidURL) }
        let fcmToken = UserDefaults.standard.object(forKey: "fcmToken") as? String ?? ""
        
        var headers: HTTPHeaders = ["Content-Type" : "multipart/form-data"]
        headers.add(name: "Authorization", value: "Bearer " + accessToken)
        
        let marketingAgree = registUserInfo.marketingAgree
        let preferExercises = registUserInfo.preferExercise.map { $0.id }
        let birth = registUserInfo.dateOfBirth ?? "123456"
        let gender = registUserInfo.sexNumber ?? "1"
        let name = registUserInfo.name ?? "임시이름"
        
        guard let nickname = registUserInfo.nickName else { return Single.error(AuthError.invalidURL) }
        let profileImage = registUserInfo.profileImage?.pngData()
        
        let parameters: Parameters = [
            "gender" : gender,
            "marketingAgree" : marketingAgree,
            "birth" : birth,
            "name" : name,
            "nickname" : nickname,
            "fcmToken" : fcmToken]
        
        return Single<RegistResponseDTO>.create { emitter in
            AF.upload(multipartFormData: { multipartFormData in
                if let profileImage {
                    multipartFormData.append(profileImage, withName: "profileImage", fileName: "\(profileImage).png", mimeType: "image/png")
                }
                
                let preferExercises = preferExercises.map { String($0) }.joined(separator: ",")
                multipartFormData.append(preferExercises.data(using: .utf8)!, withName: "preferExercises")
                
                for (key,value) in parameters {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }, to: urlString, method: .patch, headers: headers)
            .responseDecodable(of: BaseResponse<RegistResponseDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if let result = response.result {
                        emitter(.success(result))
                    } else {
                        print(response.code)
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
    func checkUserInfo(_ phoneNum: String, type: Int) -> Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/exist-phone/\(type)"
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
    
    //MARK: - 비밀번호 변경
    func resetPassword(_ registUser: AuthUserInfo)-> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/password"
        guard let newPassword = registUser.password,
              let targetPhoneNum = registUser.phoneNumber else { return Single.error(AuthError.invalidURL) }
        
        let parameters: Parameters = ["targetPhoneNum" : targetPhoneNum,
                                      "newPassword" : newPassword]
        
        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .patch, parameters: parameters, encoding: JSONEncoding.default)
                .responseDecodable(of: BaseResponse<ChangePasswordDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            emitter(.success(true))
                        } else {
                            emitter(.success(false))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                    
                }
            return Disposables.create()
        }
    }
    
    // MARK: - MyPage
    func fetchMyPage()-> Single<MyPageDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/my-page"

        return Single<MyPageDTO>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<MyPageDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
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
    
    func changeProfile(imageData: Data)-> Single<ChangeProfileDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/my-page/profile"
        guard let accessToken = KeychainManager.read("accessToken") else { return Single.error(AuthError.invalidURL) }
        
        var headers: HTTPHeaders = ["Content-Type" : "multipart/form-data"]
        headers.add(name: "Authorization", value: "Bearer " + accessToken)
        
        return Single<ChangeProfileDTO>.create { emitter in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "newProfile", fileName: "\(imageData).jpeg", mimeType: "image/jpeg")
            }, to: urlString, method: .patch, headers: headers)
            .responseDecodable(of: BaseResponse<ChangeProfileDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        guard let result = response.result else { return }
                        emitter(.success(result))
                    } else {
                        print(response.code)
                        print(response.message)
                        emitter(.failure(AuthError.serverError))
                    }
                case .failure(let error):
                    print(error)
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func setDefaultProfile()-> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/my-page/profile/default"

        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .patch, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<DefaultProfileDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        emitter(.success(true))
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
    
    func changeMainExercise(categoryId: Int)-> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/my-page/main-exercise/\(categoryId)"

        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .patch, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<ChangeMaineExerciseDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        emitter(.success(true))
                    } else {
                        emitter(.success(false))
                    }
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func getCurrentMainExercise()-> Single<CurrentExerciseDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/main-exercise"

        return Single<CurrentExerciseDTO>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<CurrentExerciseDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        guard let result = response.result else { return }
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
    
    func fetchPrivacyInfo() -> Single<PrivacyInfoDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "user/my-page/personal-data"

        return Single<PrivacyInfoDTO>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<PrivacyInfoDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        guard let result = response.result else { return }
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
    
    /// 회원탈퇴 api
    func quitAuth() -> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/quit"

        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .post, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<QuitDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        emitter(.success(true))
                    } else {
                        emitter(.success(false))
                    }
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func changePassword(newPassword: String) -> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/my-page/password"
        let parameter: Parameters = ["newPassword" : newPassword]

        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .patch, parameters: parameter, encoding: JSONEncoding.default, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<ChangePasswordDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        emitter(.success(true))
                    } else {
                        emitter(.success(false))
                    }
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func checkPassword(password: String) -> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/check-pass"
        let parameter: Parameters = ["password" : password]

        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<String>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2022 {
                        emitter(.success(true))
                    } else if response.code == 2023{
                        emitter(.success(false))
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
    
    func fetchCertificationFeed(categoryId: Int, page: Int) -> Single<CertificationFeedDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/records/\(categoryId)"
        let parameter: Parameters = ["pageIndex" : page]

        return Single<CertificationFeedDTO>.create { emitter in
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<CertificationFeedDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        guard let result = response.result else { return }
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
    
    func fetchFitSiteFeed(categoryId: Int, page: Int) -> Single<FitSiteFeedDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/articles/\(categoryId)"
        let parameter: Parameters = ["pageIndex" : page]

        return Single<FitSiteFeedDTO>.create { emitter in
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<FitSiteFeedDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        guard let result = response.result else { return }
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
    
    func fetchOtherProfileInfo(userId: Int) -> Single<BaseResponse<OtherUserInfoDTO>> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/\(userId)"

        return Single<BaseResponse<OtherUserInfoDTO>>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
                .responseString() { res in
                    switch res.result {
                    case .success(let response):
                        print(response)
                    case .failure(let error):
                        print(error)
//                        emitter(.failure(error))
                    }
                }
            .responseDecodable(of: BaseResponse<OtherUserInfoDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    emitter(.success(response))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchOtherUserArticle(userId: Int, categoryId: Int, page: Int) -> Single<FitSiteFeedDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/\(userId)/articles/\(categoryId)"
        let parameter: Parameters = ["pageIndex" : page]
        return Single<FitSiteFeedDTO>.create { emitter in
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<FitSiteFeedDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        guard let result = response.result else { return }
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
    
    func reportUser(userId: Int) -> Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/\(userId)/report"
        
        return Single<Int>.create { emitter in
            AF.request(urlString, method: .post, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<ReportUserDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    emitter(.success(response.code))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func logout() -> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "users/logout"
        
        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .post, interceptor: AuthManager())
            .responseDecodable(of: BaseResponse<LogoutDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        emitter(.success(true))
                    } else {
                        emitter(.success(false))
                    }
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
