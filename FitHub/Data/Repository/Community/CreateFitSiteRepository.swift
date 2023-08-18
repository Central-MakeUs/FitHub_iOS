//
//  CreateFitSiteRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/11.
//

import Foundation
import RxSwift

protocol CreateFitSiteRepositoryInterface {
    func fetchCategory() -> Single<[CategoryDTO]>
    func fetchArticles(categoryId: Int, page: Int, sortingType: SortingType) -> Single<FitSiteFeedDTO>
    func createArticle(categoryId: Int, feedInfo: EditFitSiteModel)->Single<Bool>
}

final class CreateFitSiteRepository: CreateFitSiteRepositoryInterface {
    private let authService: UserService
    private let articleService: ArticleService
    
    init(authService: UserService,
         articleService: ArticleService) {
        self.authService = authService
        self.articleService = articleService
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return authService.fetchCategory()
    }
    
    func fetchArticles(categoryId: Int, page: Int, sortingType: SortingType) -> Single<FitSiteFeedDTO> {
        return articleService.fetchArticles(categoryId: categoryId, page: page, sortingType: sortingType)
    }
    
    func createArticle(categoryId: Int, feedInfo: EditFitSiteModel)->Single<Bool> {
        return articleService.createArticle(categoryId: categoryId, feedInfo: feedInfo)
    }
}
