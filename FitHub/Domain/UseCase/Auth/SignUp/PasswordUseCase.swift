//
//  PasswordUsecase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation

protocol PasswordUseCaseProtocol {
    var registUserInfo: AuthUserInfo { get set }
    
    func verifyPassword(_ password: String) -> UserInfoStatus
    func verifyPasswordVerification(_ passwordVerification: String, _ password: String) -> UserInfoStatus
}


class PasswordUseCase: PasswordUseCaseProtocol {
    var registUserInfo: AuthUserInfo
    
    init(_ authUserInfo: AuthUserInfo) {
        self.registUserInfo = authUserInfo
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
