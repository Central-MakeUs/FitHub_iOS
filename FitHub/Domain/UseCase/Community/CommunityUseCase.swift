//
//  CommunityUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol CommunityUseCaseProtocol {
    func fetchCertificationFeed(id: Int, page: Int, sortingType: SortingType)-> Single<CertificationFeedDTO>
    func fetchFitSiteFeed(_ cateogryId: Int, page: Int, type: SortingType) -> Single<FitSiteFeedDTO>
    func fetchCategory()->Single<[CategoryDTO]>
    func checkHasTodayCertification()->Single<CheckTodayDTO>
}

final class CommunityUseCase: CommunityUseCaseProtocol {
    private let disposeBag = DisposeBag()
    private let repository: CommunityRepositoryInterface

    init(_ repository: CommunityRepositoryInterface) {
        self.repository = repository
    }
    
    func fetchCategory()->Single<[CategoryDTO]> {
        return repository.fetchCategory()
            .map { [CategoryDTO(createdAt: nil, updatedAt: nil, imageUrl: nil, name: "전체", id: 0)] + $0 }
    }
    
    func fetchCertificationFeed(id: Int, page: Int, sortingType: SortingType)-> Single<CertificationFeedDTO> {
        return self.repository
            .fetchCertificationFeed(id, pageIndex: page, type: sortingType)
    }
    
    func fetchFitSiteFeed(_ cateogryId: Int, page: Int, type: SortingType) -> Single<FitSiteFeedDTO> {
        return self.repository.fetchFitSiteFeed(cateogryId, page: page, type: type)
    }
    
    func checkHasTodayCertification()->Single<CheckTodayDTO> {
        return repository.checkHasTodayCertification()
    }
}
