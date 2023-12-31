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
    func checkUserInfo(_ phoneNum: String, type: Int) -> Single<Int>
    
    var userInfo: AuthUserInfo { get set }
}

class FindPWUseCase: FindPWUseCaseProtocol {
    private let repository: FindPWRepositoryInterface
    var userInfo = AuthUserInfo()
    
    init(_ repository: FindPWRepositoryInterface) {
        self.repository = repository
    }
    
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus {
        let phoneNumberRegex = "^010\\d{8}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: numberStr)
        
        return isValid ? .ok : .notValidPhoneNumber
    }
    
    func checkUserInfo(_ phoneNum: String, type: Int) -> Single<Int> {
        return repository.checkUserInfo(phoneNum, type: type)
    }
}
