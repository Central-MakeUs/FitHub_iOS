//
//  ResetPWUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/19.
//

import Foundation
import RxSwift

protocol ResetPWUseCaseProtocol {
    func verifyPassword(_ password: String) -> UserInfoStatus
    func verifyPasswordVerification(_ passwordVerification: String, _ password: String) -> UserInfoStatus
    func checkPassword(password: String) -> Single<Bool>
    func changePassword(newPassword: String) -> Single<Bool>
}

final class ResetPWUseCase: ResetPWUseCaseProtocol {
    private let mypageRepository: MyPageRepositoryInterface
    
    init(mypageRepository: MyPageRepositoryInterface) {
        self.mypageRepository = mypageRepository
    }
    
    func checkPassword(password: String) -> Single<Bool> {
        return mypageRepository.checkPassword(password: password)
    }
    
    func changePassword(newPassword: String) -> Single<Bool> {
        return mypageRepository.changePassword(newPassword: newPassword)
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
        if passwordVerification.isEmpty {
            return .ok
        }
        
        if passwordVerification == password {
            return .matchPassword
        } else {
            return .notMatchPassword
        }
    }
}
