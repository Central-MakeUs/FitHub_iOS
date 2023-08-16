//
//  SearchUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation
import RxSwift

protocol SearchUseCaseProtocol {
    func searchTotalItem(tag: String)->Single<SearchTotalDTO?>
    func searchCertification(tag: String, page: Int, type: SortingType)->Single<CertificationFeedDTO?>
    func searchToFitSite(tag: String, page: Int, type: SortingType)->Single<FitSiteFeedDTO?>
    func fetchRecommendKeyword()->Single<RecommendKeywordDTO>
}

final class SearchUseCase: SearchUseCaseProtocol {
    let searchRepository: SearchRepositoryInterface
    
    init(searchRepository: SearchRepositoryInterface) {
        self.searchRepository = searchRepository
    }
    
    func searchTotalItem(tag: String)->Single<SearchTotalDTO?> {
        return searchRepository.searchTotalItem(tag: tag)
    }
    
    func searchCertification(tag: String, page: Int, type: SortingType)->Single<CertificationFeedDTO?> {
        return searchRepository.searchCertification(tag: tag, page: page, type: type)
    }
    
    func searchToFitSite(tag: String, page: Int, type: SortingType)->Single<FitSiteFeedDTO?> {
        return searchRepository.searchToFitSite(tag: tag, page: page, type: type)
    }
    
    func fetchRecommendKeyword()->Single<RecommendKeywordDTO> {
        return searchRepository.fetchRecommendKeyword()
    }
}
