//
//  PhoneNumLoginUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/22.
//

import Foundation
import RxSwift

protocol PhoneNumLoginUseCaseProtocol {
    func signInWithPhoneNumber(_ phoneNum: String,_ password: String) -> Single<PhoneNumLoginDTO>
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus
}

class PhoneNumLoginUseCase: PhoneNumLoginUseCaseProtocol {
    private let repository: PhoneAuthRepositoryInterface
    
    init(_ repository: PhoneAuthRepositoryInterface) {
        self.repository = repository
    }
    
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus {
        let phoneNumberRegex = "^010\\d{8}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: numberStr)
        
        return isValid ? .ok : .notValidPhoneNumber
    }
    
    func signInWithPhoneNumber(_ phoneNum: String,_ password: String) -> Single<PhoneNumLoginDTO> {
        return repository.signInWithPhoneNumber(password, password)
    }
}
