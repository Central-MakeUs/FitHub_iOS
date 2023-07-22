//
//  AuthRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/22.
//

import Foundation
import RxSwift

protocol AuthRepositoryInterface {
    func signInWithApple(_ token: String) -> Single<OAuthLoginDTO>
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO>
    func signInWithPhoneNumber(_ phoneNum: String,_ password: String) -> Single<PhoneNumLoginDTO>
    
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int>
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus>
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int>
    func checkUserInfo(_ phoneNum: String) -> Single<Int>
}


final class AuthRepository: AuthRepositoryInterface {
    private let service: AuthService
    
    init(_ service: AuthService) {
        self.service = service
    }
    
    func signInWithApple(_ token: String) -> Single<OAuthLoginDTO> {
        return service.signInAppleLogin(token)
    }
    
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO> {
        return service.signInKakaoLogin(socialId)
    }
    
    func signInWithPhoneNumber(_ phoneNum: String, _ password: String) -> Single<PhoneNumLoginDTO> {
        return service.signInPhoneNumber(phoneNum, password)
    }
    
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int> {
        return service.sendAuthenticationNumber(phoneNum)
    }
    
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus> {
        return self.service.duplicationNickNameCheck(nickName)
            .map { $0 ? .duplicateNickName : .nickNameSuccess }
    }
    
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int> {
        return service.verifyAuthenticationNumber(phoneNum, authNum)
    }
    
    func checkUserInfo(_ phoneNum: String) -> Single<Int> {
        return service.checkUserInfo(phoneNum)
    }
}
