//
//  OAuthLoginRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import Foundation
import RxSwift

protocol OAuthLoginRepositoryInterface {
    func signInWithApple(_ token: String) -> Single<OAuthLoginDTO>
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO>
}

final class OAuthLoginRepository: OAuthLoginRepositoryInterface {
    private let service: UserService
    
    init(_ service: UserService) {
        self.service = service
    }
    
    func signInWithApple(_ token: String) -> Single<OAuthLoginDTO> {
        return service.signInAppleLogin(token)
    }
    
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO> {
        return service.signInKakaoLogin(socialId)
    }
}
