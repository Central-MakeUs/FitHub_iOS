//
//  LoginUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import RxSwift
import Foundation

protocol OAuthLoginUseCaseProtocol {
    func signInWithApple(_ token: String, name: String) -> Single<OAuthLoginDTO>
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO>
}

class OAuthLoginUseCase: OAuthLoginUseCaseProtocol {
    private let repository: OAuthLoginRepositoryInterface
    
    func signInWithApple(_ token: String, name: String) -> Single<OAuthLoginDTO> {
        return repository.signInWithApple(token, name: name)
    }
    
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO> {
        return repository.signInWithKakao(socialId)
    }
    
    init(_ repository: OAuthLoginRepositoryInterface) {
        self.repository = repository
    }
}
