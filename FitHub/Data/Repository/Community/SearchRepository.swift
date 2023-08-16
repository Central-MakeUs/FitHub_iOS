//
//  SearchRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation
import RxSwift

protocol SearchRepositoryInterface {
    func searchTotalItem(tag: String)->Single<SearchTotalDTO?>
    func searchCertification(tag: String, page: Int, type: SortingType)->Single<CertificationFeedDTO?>
    func searchToFitSite(tag: String, page: Int, type: SortingType)->Single<FitSiteFeedDTO?>
    func fetchRecommendKeyword()->Single<RecommendKeywordDTO>
}

final class SearchRepository: SearchRepositoryInterface {
    private let service: SearchService
    
    init(service: SearchService) {
        self.service = service
    }
    
    func searchTotalItem(tag: String)->Single<SearchTotalDTO?> {
        return service.searchTotalItem(tag: tag)
    }
    
    func searchCertification(tag: String, page: Int, type: SortingType)->Single<CertificationFeedDTO?> {
        return service.searchCertification(tag: tag, page: page, type: type)
    }
    
    func searchToFitSite(tag: String, page: Int, type: SortingType)->Single<FitSiteFeedDTO?> {
        return service.searchToFitSite(tag: tag, page: page, type: type)
    }
    
    func fetchRecommendKeyword()->Single<RecommendKeywordDTO> {
        return service.fetchRecommendKeyword()
    }
}
