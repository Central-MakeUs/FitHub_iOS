//
//  CreateFitSiteUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/11.
//

import Foundation
import RxSwift

protocol CreateFitSiteUseCaseProtocol {
    func fetchCategory() -> Single<[CategoryDTO]>
    func fetchArticles(categoryId: Int, page: Int, sortingType: SortingType) -> Single<FitSiteFeedDTO>
    func createArticle(categoryId: Int, feedInfo: EditFitSiteModel)->Single<Bool>
}

final class CreateFitSiteUseCase: CreateFitSiteUseCaseProtocol {
    let repository: CreateFitSiteRepositoryInterface
    
    init(repository: CreateFitSiteRepositoryInterface) {
        self.repository = repository
        
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return repository.fetchCategory()
    }
    
    func fetchArticles(categoryId: Int, page: Int, sortingType: SortingType) -> Single<FitSiteFeedDTO> {
        repository.fetchArticles(categoryId: categoryId, page: page, sortingType: sortingType)
    }
    
    func createArticle(categoryId: Int, feedInfo: EditFitSiteModel)->Single<Bool> {
        repository.createArticle(categoryId: categoryId, feedInfo: feedInfo)
    }
}
