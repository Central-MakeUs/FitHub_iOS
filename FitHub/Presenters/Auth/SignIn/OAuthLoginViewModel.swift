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
    
    var loginPublisher = PublishSubject<Result<OAuthLoginDTO,AuthError>>()
    
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
        let familyName = credential.fullName?.familyName ?? ""
        let givenName = credential.fullName?.givenName ?? ""
        let fullName = familyName + givenName
        
        self.usecase.signInWithApple(tokenString, name: fullName)
            .subscribe(onSuccess: { [weak self] res in
                KeychainManager.create(key: "accessToken", value: res.accessToken)
                KeychainManager.create(key: "userId", value: String(res.userId))
                if let userName = res.userName { UserDefaults.standard.setValue(userName, forKey: "appleName") }
                self?.loginPublisher.onNext(.success(res))
            }, onFailure: { [weak self] error in
                self?.loginPublisher.onNext(.failure(error as! AuthError))
            })
            .disposed(by: disposeBag)
    }
    
    func requestLogin() {
        UserApi.shared.rx.me()
            .compactMap { $0.id }
            .map { String($0) }
            .flatMap { self.usecase.signInWithKakao($0).asMaybe() }
            .subscribe(onSuccess: { [weak self] res in
                self?.loginPublisher.onNext(.success(res))
                KeychainManager.create(key: "accessToken", value: res.accessToken)
                KeychainManager.create(key: "userId", value: String(res.userId))
            }, onError: { [weak self] error in
                self?.loginPublisher.onNext(.failure(error as! AuthError))
            })
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
