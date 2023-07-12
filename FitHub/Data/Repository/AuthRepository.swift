//
//  OAuthLoginRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import Foundation
import RxSwift

class AuthRepository: OAuthLoginUseCase {
    private let authService: AuthService
    
    func signInWithApple(_ token: String) -> RxSwift.Single<String> {
        return authService.signInAppleLogin(token)
            
    }
    
    init(_ service: AuthService = AuthService()) {
        self.authService = service
    }
}
