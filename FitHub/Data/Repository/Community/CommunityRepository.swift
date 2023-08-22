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
    func deleteCertifications(recordIdList: [Int])->Single<CertificationDeleteRecordsDTO>
    func deleteFitSites(articleIdList: [Int])->Single<DeleteFitSitesDTO>
    func reportUser(userId: Int) -> Single<Int>
    func checkHasTodayCertification()->Single<CheckTodayDTO>
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
    
    func deleteCertifications(recordIdList: [Int])->Single<CertificationDeleteRecordsDTO> {
        return certificationService.deleteCertifications(recordIdList: recordIdList)
    }
    
    func deleteFitSites(articleIdList: [Int])->Single<DeleteFitSitesDTO> {
        return articleService.deleteFitSites(articleIdList: articleIdList)
    }
    
    func reportUser(userId: Int) -> Single<Int> {
        return authService.reportUser(userId: userId)
    }
    
    func checkHasTodayCertification()->Single<CheckTodayDTO> {
        return certificationService.checkHasTodayCertification()
    }
}
