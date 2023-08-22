//
//  CertificationDetailRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import Foundation
import RxSwift

protocol CertificationRepositoryInterface {
    func fecthCertification(_ categoryId: Int, pageIndex: Int, type: SortingType)->Single<CertificationFeedDTO>
    func fetchCertificationDetail(recordId: Int)->Single<CertificationDetailDTO>
    func createCertification(_ certificationInfo: CreateCertificationModel) -> Single<CreateCertificationDTO>
    func reportCertification(recordId: Int)->Single<Int>
    func removeCertification(recordId: Int)->Single<Int>
    func toggleLikeCertification(recordId: Int)->Single<LikeCertificationDTO>
    func updateCertification(recordId: Int, certificationInfo: CreateCertificationModel, remainImageUrl: String?) -> Single<UpdateCertificationDTO>
}

final class CertificationRepository: CertificationRepositoryInterface {
    private let service: CertificationService
    
    init(service: CertificationService) {
        self.service = service
    }
    
    func fecthCertification(_ categoryId: Int, pageIndex: Int, type: SortingType)->Single<CertificationFeedDTO> {
        return service.fecthCertification(categoryId, pageIndex: pageIndex, type: type)
    }
    
    func createCertification(_ certificationInfo: CreateCertificationModel) -> Single<CreateCertificationDTO> {
        return service.createCertification(certificationInfo)
    }
    
    func fetchCertificationDetail(recordId: Int)->Single<CertificationDetailDTO> {
        return service.fetchCertifiactionDetail(recordId: recordId)
    }
    
    func reportCertification(recordId: Int)->Single<Int> {
        return service.reportCertification(recordId: recordId)
    }
    
    func removeCertification(recordId: Int)->Single<Int> {
        return service.removeCertification(recordId: recordId)
    }
    
    func toggleLikeCertification(recordId: Int)->Single<LikeCertificationDTO> {
        return service.toggleLikeCertification(recordId: recordId)
    }
    
    func updateCertification(recordId: Int, certificationInfo: CreateCertificationModel, remainImageUrl: String?) -> Single<UpdateCertificationDTO> {
        return service.updateCertification(recordId: recordId, certificationInfo: certificationInfo, remainImageUrl: remainImageUrl)
    }
}
