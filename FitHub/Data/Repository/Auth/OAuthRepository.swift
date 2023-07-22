//
//  OAuthLoginRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import Foundation
import RxSwift

protocol OAuthRepositoryInterface {
    func signInWithApple(_ token: String) -> Single<OAuthLoginDTO>
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO>
}

class OAuthRepository: OAuthRepositoryInterface {
    private let authService: AuthService
    
    func signInWithApple(_ token: String) -> Single<OAuthLoginDTO> {
        return self.authService.signInAppleLogin(token)
    }
    
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO> {
        return self.authService.signInKakaoLogin(socialId)
    }
    
    init(_ service: AuthService) {
        self.authService = service
    }
}
