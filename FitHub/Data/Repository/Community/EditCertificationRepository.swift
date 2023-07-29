//
//  EditCertificationRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation

protocol EditCertificationRepositoryInterface {
    
}

final class EditCertificationRepository: EditCertificationRepositoryInterface {
    private let certificationService: CertificationService
    
    init(certificationService: CertificationService) {
        self.certificationService = certificationService
    }
}
