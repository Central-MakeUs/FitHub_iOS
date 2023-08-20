//
//  EditCertificationRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation
import RxSwift

protocol EditCertificationRepositoryInterface {
    func fetchCategory() -> Single<[CategoryDTO]>
    func createCertification(_ certificationInfo: EditCertificationModel) -> Single<CreateCertificationDTO>
}

final class EditCertificationRepository: EditCertificationRepositoryInterface {
    private let certificationService: CertificationService
    private let authService: UserService
    
    init(certificationService: CertificationService,
         authService: UserService) {
        self.certificationService = certificationService
        self.authService = authService
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return authService.fetchCategory()
    }
    
    func createCertification(_ certificationInfo: EditCertificationModel) -> Single<CreateCertificationDTO> {
        return certificationService.createCertification(certificationInfo)
    }
}
