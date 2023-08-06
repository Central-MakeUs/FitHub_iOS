//
//  CommunityRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation
import RxSwift

protocol CommunityRepositoryInterface {
    func fetchCategory() -> Single<[CategoryDTO]>
    func fetchCertificationFeed(_ categoryId: Int, pageIndex: Int, type: OrderType) -> Single<CertificationFeedDTO>
}

final class CommunityRepository: CommunityRepositoryInterface {
    private let authService: AuthService
    private let certificationService: CertificationService
    
    init(_ authService: AuthService,
         certificationService: CertificationService) {
        self.authService = authService
        self.certificationService = certificationService
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return self.authService.fetchCategory()
    }
    
    func fetchCertificationFeed(_ categoryId: Int, pageIndex: Int, type: OrderType) -> Single<CertificationFeedDTO> {
        return self.certificationService.fecthCertification(categoryId, pageIndex: pageIndex, type: type)
    }
}
