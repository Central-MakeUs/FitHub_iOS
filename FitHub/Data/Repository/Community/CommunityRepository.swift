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
    func fetchCertificationFeed(_ categoryId: Int, pageIndex: Int, type: SortingType) -> Single<CertificationFeedDTO>
    func fetchFitSiteFeed(_ cateogryId: Int, page: Int, type: SortingType) -> Single<FitSiteFeedDTO>
}

final class CommunityRepository: CommunityRepositoryInterface {
    private let authService: UserService
    private let certificationService: CertificationService
    private let articleService: ArticleService
    
    init(_ authService: UserService,
         certificationService: CertificationService,
         articleService: ArticleService) {
        self.authService = authService
        self.certificationService = certificationService
        self.articleService = articleService
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return self.authService.fetchCategory()
    }
    
    func fetchCertificationFeed(_ categoryId: Int, pageIndex: Int, type: SortingType) -> Single<CertificationFeedDTO> {
        return self.certificationService.fecthCertification(categoryId, pageIndex: pageIndex, type: type)
    }
    
    func fetchFitSiteFeed(_ cateogryId: Int, page: Int, type: SortingType) -> Single<FitSiteFeedDTO> {
        return self.articleService.fetchArticles(categoryId: cateogryId, page: page, sortingType: type)
    }
}
