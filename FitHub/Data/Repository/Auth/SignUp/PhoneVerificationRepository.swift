//
//  PhoneVerificationRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import Foundation
import RxSwift

protocol PhoneVerificationRepositoryInterface {
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int>
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int>
}

final class PhoneVerificationRepository: PhoneVerificationRepositoryInterface {
    private let service: AuthService
    
    init(_ service: AuthService) {
        self.service = service
    }
    
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int> {
        return service.sendAuthenticationNumber(phoneNum)
    }
    
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int> {
        return service.verifyAuthenticationNumber(phoneNum, authNum)
    }
}
