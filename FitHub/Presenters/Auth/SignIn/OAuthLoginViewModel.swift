//
//  AuthViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//

import Foundation
import RxSwift
import AuthenticationServices
import KakaoSDKUser

class OAuthLoginViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private let usecase: OAuthLoginUseCase
    
    var loginPublisher = PublishSubject<OAuthLoginDTO>()
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init(_ usecase: OAuthLoginUseCase) {
        self.usecase = usecase
    }
    
    func requestLogin(_ credential: ASAuthorizationAppleIDCredential) {
        guard let token = credential.identityToken,
              let tokenString = String(data: token, encoding: .utf8) else { return }
        
        self.usecase.signInWithApple(tokenString)
            .subscribe(onSuccess: { [weak self] str in
                self?.loginPublisher.onNext(str)
            }, onFailure: { [weak self] error in
                self?.loginPublisher.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func requestLogin() {
        UserApi.shared.rx.me()
            .compactMap { $0.id }
            .map { String($0) }
            .flatMap { self.usecase.signInWithKakao($0).asMaybe() }
            .subscribe (onSuccess: { [weak self] str in
                self?.loginPublisher.onNext(str)
            }, onError: { [weak self] error in
                self?.loginPublisher.onError(error)
            })
            .disposed(by: disposeBag)
            
            
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
