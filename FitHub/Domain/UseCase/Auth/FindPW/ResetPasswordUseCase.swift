//
//  ResetPasswordUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation
import RxSwift

protocol ResetPasswordUseCaseProtocol {
    var userInfo: AuthUserInfo { get set }
    
    func verifyPassword(_ password: String) -> UserInfoStatus
    func verifyPasswordVerification(_ passwordVerification: String, _ password: String) -> UserInfoStatus
    
    func changePassword() -> Single<Bool>
}

final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    private let repository: ResetPasswordRepositoryInterface
    var userInfo: AuthUserInfo
    
    init(_ repository: ResetPasswordRepositoryInterface,
         userInfo: AuthUserInfo) {
        self.userInfo = userInfo
        self.repository = repository
    }
    
    func changePassword() -> Single<Bool> {
        return self.repository.resetPassword(userInfo)
    }
    
    func verifyPassword(_ password: String) -> UserInfoStatus {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d|.*[^A-Za-z0-9]).+$"
        
        if password.count == 0 {
            return .passwordOK
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password) {
            return .notValidPassword
        }
        
        if password.count < 8 || password.count > 16 {
            return .passwordLengthError
        }
        
        return .passwordSuccess
    }
    
    func verifyPasswordVerification(_ passwordVerification: String, _ password: String) -> UserInfoStatus {
        if passwordVerification.count == 0 {
            return .ok
        }
        
        if passwordVerification == password {
            return .matchPassword
        } else {
            return .notMatchPassword
        }
    }
}
