//
//  RegistInfoUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/11.
//

import Foundation
import RxSwift

protocol RegistInfoUseCaseProtocol {
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus 
    func verifyDateOfBirth(_ dateStr: String, sexNumStr: String) -> UserInfoStatus
}

class RegistInfoUseCase: RegistInfoUseCaseProtocol {
    private let repository: RegistInfoRepositoryInterface
    
    init(_ repository: RegistInfoRepositoryInterface) {
        self.repository = repository
    }
    
    func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus {
        let phoneNumberRegex = "^010\\d{8}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: numberStr)
        
        return isValid ? .ok : .notValidPhoneNumber
    }
    
    func verifyDateOfBirth(_ dateStr: String, sexNumStr: String) -> UserInfoStatus {
        guard dateStr.count == 6 && sexNumStr.count == 1 else { return .ok }
        
        let sexNumRegex = "^[1-4]$"
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "YYMMdd"
        
        if let birthDate = dateFormatter.date(from: dateStr) {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
            if let age = ageComponents.year,
               age < 14 {
                return .underage
            }
        } else {
            return .notValidDateOfBirth
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", sexNumRegex).evaluate(with: sexNumStr) {
            return .notValidSexNumber
        }
        
        return .ok
    }
}
