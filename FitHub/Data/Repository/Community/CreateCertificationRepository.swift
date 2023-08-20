//
//  CreateCertificationRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation
import RxSwift

protocol CreateCertificationRepositoryInterface {
    func fetchCategory() -> Single<[CategoryDTO]>
    func createCertification(_ certificationInfo: CreateCertificationModel) -> Single<CreateCertificationDTO>
    func updateCertification(recordId: Int, certificationInfo: CreateCertificationModel) -> Single<UpdateCertificationDTO>
}

final class CreateCertificationRepository: CreateCertificationRepositoryInterface {
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
    
    func createCertification(_ certificationInfo: CreateCertificationModel) -> Single<CreateCertificationDTO> {
        return certificationService.createCertification(certificationInfo)
    }
    
    func updateCertification(recordId: Int, certificationInfo: CreateCertificationModel) -> Single<UpdateCertificationDTO> {
        return certificationService.updateCertification(recordId: recordId, certificationInfo: certificationInfo)
    }
}
