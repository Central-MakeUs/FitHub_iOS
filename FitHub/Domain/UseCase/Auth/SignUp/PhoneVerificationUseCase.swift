//
//  PhoneVerificationUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/22.
//

import Foundation
import RxSwift

protocol PhoneVerificationUseCaseProtocol {
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int>
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int>
}

final class PhoneVerificationUseCase: PhoneVerificationUseCaseProtocol {
    private let repository: PhoneVerificationRepositoryInterface
    
    init(repository: PhoneVerificationRepositoryInterface) {
        self.repository = repository
    }
    
    func sendAuthenticationNumber(_ phoneNum: String) -> Single<Int> {
        return repository.sendAuthenticationNumber(phoneNum)
    }
    
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int> {
        return repository.verifyAuthenticationNumber(phoneNum, authNum)
    }
}
