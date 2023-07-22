//
//  FindPWUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation
import RxSwift

protocol FindPWUseCaseProtocol {
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int>
    func checkUserInfo(_ phoneNum: String) -> Single<Int>
}

class FindPWUseCase: FindPWUseCaseProtocol {
    private let repository: AuthRepositoryInterface
    
    init(_ repository: AuthRepositoryInterface) {
        self.repository = repository
    }
    
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int> {
        return repository.sendAuthenticationNumber(phoneNum)
    }
    
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus {
        let phoneNumberRegex = "^010\\d{8}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: numberStr)
        
        return isValid ? .ok : .notValidPhoneNumber
    }
    
    func checkUserInfo(_ phoneNum: String) -> Single<Int> {
        return repository.checkUserInfo(phoneNum)
    }
}
