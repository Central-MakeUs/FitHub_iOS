//
//  OAuthRegistInputUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation

protocol OAuthRegistInputUseCaseProtocol {
    var registUserInfo: AuthUserInfo { get set }
    
    func verifyDateOfBirth(_ dateStr: String, sexNumStr: String) -> UserInfoStatus
}

final class OAuthRegistInputUseCase: OAuthRegistInputUseCaseProtocol {
    var registUserInfo: AuthUserInfo
    
    init(registUserInfo: AuthUserInfo) {
        self.registUserInfo = registUserInfo
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
