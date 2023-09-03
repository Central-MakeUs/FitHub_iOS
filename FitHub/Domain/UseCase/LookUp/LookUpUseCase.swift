//
//  LookUpUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/27.
//

import Foundation
import RxSwift

protocol LookUpUseCaseProtocol {
    func fetchCategory()->Single<[CategoryDTO]>
    func fetchFacilities(searchInfo: FacilitySearch)->Single<FacilitiesDTO>
    func fetchRecommendFacilites() -> Single<RecommendKeywordDTO>
    func fetchFacilitiesWithKeyword(searchInfo: FacilitySearch)-> Single<FacilitiesKeywordDTO>
}

final class LookUpUseCase: LookUpUseCaseProtocol {
    private let lookUpRepo: LookUpRepositioryInterface
    
    init(lookUpRepo: LookUpRepositioryInterface) {
        self.lookUpRepo = lookUpRepo
    }
    
    func fetchCategory()->Single<[CategoryDTO]> {
        return lookUpRepo.fetchCategory().map { [CategoryDTO(createdAt: nil, updatedAt: nil, imageUrl: nil, name: "전체", id: 0)] + $0 }
    }
    
    func fetchFacilities(searchInfo: FacilitySearch)->Single<FacilitiesDTO> {
        return lookUpRepo.fetchFacilities(searchInfo: searchInfo)
    }
    
    func fetchRecommendFacilites() -> Single<RecommendKeywordDTO> {
        return lookUpRepo.fetchRecommendFacilites()
    }
    
    func fetchFacilitiesWithKeyword(searchInfo: FacilitySearch)-> Single<FacilitiesKeywordDTO> {
        return lookUpRepo.fetchFacilitiesWithKeyword(searchInfo: searchInfo)
    }
}
