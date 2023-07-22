//
//  PhoneAuthRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/22.
//

import Foundation
import RxSwift

protocol PhoneAuthRepositoryInterface {
    func signInWithPhoneNumber(_ phoneNum: String,_ password: String) -> Single<PhoneNumLoginDTO>
}

final class PhoneAuthRepository: PhoneAuthRepositoryInterface {
    private let service: AuthService
    
    func signInWithPhoneNumber(_ phoneNum: String, _ password: String) -> Single<PhoneNumLoginDTO> {
        return service.signInPhoneNumber(phoneNum, password)
    }
    
    init(_ authService: AuthService) {
        self.service = authService
    }
}
