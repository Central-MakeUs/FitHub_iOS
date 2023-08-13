//
//  CertificationDetailRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import Foundation
import RxSwift

protocol CertificationDetailRepositoryInterface {
    func fetchCertificationDetail(recordId: Int)->Single<CertificationDetailDTO>
}

final class CertificationDetailRepository: CertificationDetailRepositoryInterface {
    private let service: CertificationService
    
    init(service: CertificationService) {
        self.service = service
    }
    
    func fetchCertificationDetail(recordId: Int)->Single<CertificationDetailDTO> {
        return service.fetchCertifiactionDetail(recordId: recordId)
    }
}
