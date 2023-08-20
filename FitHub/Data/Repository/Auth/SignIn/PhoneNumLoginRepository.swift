//
//  PhoneNumLoginRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import Foundation
import RxSwift

protocol PhoneNumLoginRepositoryInterface {
    func signInWithPhoneNumber(_ phoneNum: String,_ password: String) -> Single<PhoneNumLoginDTO>
}

final class PhoneNumLoginRepository: PhoneNumLoginRepositoryInterface {
    private let service: UserService
    
    init(_ service: UserService) {
        self.service = service
    }
    
    func signInWithPhoneNumber(_ phoneNum: String, _ password: String) -> Single<PhoneNumLoginDTO> {
        return service.signInPhoneNumber(phoneNum, password)
    }
}
