//
//  FindPWUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation

protocol FindPWUseCase {
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus
}

class FindPWInteractor: FindPWUseCase {
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus {
        let phoneNumberRegex = "^010\\d{8}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: numberStr)
        
        return isValid ? .ok : .notValidPhoneNumber
    }
}
