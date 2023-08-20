//
//  EditCertificationUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import Foundation
import RxSwift

protocol EditCertificationUseCaseProtocol {
    func fetchCategory() -> Single<[CategoryDTO]>
    func updateCertification(recordId: Int, certificationInfo: CreateCertificationModel, remainImageUrl: String?) -> Single<UpdateCertificationDTO>
}

final class EditCertificationUseCase: EditCertificationUseCaseProtocol {
    private let certificationRepo: CertificationRepositoryInterface
    private let userRepo: UserRepositoryInterface
    
    init(certificationRepo: CertificationRepositoryInterface,
         userRepo: UserRepositoryInterface) {
        self.certificationRepo = certificationRepo
        self.userRepo = userRepo
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return userRepo.fetchCategory()
    }
    
    func updateCertification(recordId: Int, certificationInfo: CreateCertificationModel, remainImageUrl: String?) -> Single<UpdateCertificationDTO> {
        return certificationRepo.updateCertification(recordId: recordId, certificationInfo: certificationInfo, remainImageUrl: remainImageUrl)
    }
}
