//
//  AgreementModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/28.
//

import Foundation

class AgreementModel {
    var privateAgreement: Bool = false
    
    var useAgreement: Bool = false
    
    var locationAgreement: Bool = false
    
    var ageAgreement: Bool = false
    
    var marketingAgreement: Bool = false
    
    func allToggleCheck(_ shouldCheck: Bool) {
        self.privateAgreement = shouldCheck
        self.useAgreement = shouldCheck
        self.locationAgreement = shouldCheck
        self.ageAgreement = shouldCheck
        self.marketingAgreement = shouldCheck
    }
}
