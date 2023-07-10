//
//  AuthViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//

import Foundation
import RxSwift
import AuthenticationServices

class OAuthLoginViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private let repository: OAuthLoginUseCase
    
    var loginPublisher = PublishSubject<String>()
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init(_ repository: OAuthLoginUseCase = AuthRepository()) {
        self.repository = repository
    }
    
    func requestLogin(_ credential: ASAuthorizationAppleIDCredential) {
        guard let token = credential.identityToken,
              let tokenString = String(data: token, encoding: .utf8) else { return }
        
        self.repository.signInWithApple(tokenString)
            .subscribe(onSuccess: { [weak self] str in
                self?.loginPublisher.onNext(str)
            }, onFailure: { [weak self] error in
                self?.loginPublisher.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
