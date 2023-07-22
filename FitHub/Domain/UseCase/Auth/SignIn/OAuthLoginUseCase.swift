//
//  LoginUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import RxSwift
import Foundation

protocol OAuthLoginUseCaseProtocol {
    func signInWithApple(_ token: String) -> Single<OAuthLoginDTO>
    func signInWithKakao(_ socialId: String) -> Single<OAuthLoginDTO>
}

class OAuthLoginUseCase: OAuthLoginUseCaseProtocol {
    private let repository: OAuthRepositoryInterface
    
    func signInWithApple(_ token: String) -> Single<OAuthLoginDTO> {
        return repository.signInWithApple(token)
    }
    
    func signInWithKakao(_ socialId: String) -> RxSwift.Single<OAuthLoginDTO> {
        return repository.signInWithKakao(socialId)
    }
    
    init(_ authRepository: OAuthRepositoryInterface) {
        self.repository = authRepository
    }
}
