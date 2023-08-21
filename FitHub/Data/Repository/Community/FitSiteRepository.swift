//
//  FitSiteRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import Foundation
import RxSwift

protocol FitSiteRepositoryInterface {
    func fetchFitSiteDetail(articleId: Int)->Single<FitSiteDetailDTO>
    func toggleLikeFitSite(articleId: Int)->Single<LikeFitSiteDTO>
    func scrapFitSite(articleId: Int)->Single<FitSiteScrapDTO>
    func reportFitSite(articleId: Int)->Single<Int>
    func deleteFitSite(articleId: Int)->Single<Bool>
    func updateArticle(articleId: Int, feedInfo: EditFitSiteModel, remainImageList: [String])->Single<Bool>
}

final class FitSiteRepository: FitSiteRepositoryInterface {
    private let service: ArticleService
    
    init(service: ArticleService) {
        self.service = service
    }
    
    func fetchFitSiteDetail(articleId: Int)->Single<FitSiteDetailDTO> {
        return service.fetchFitSiteDetail(articleId: articleId)
    }
    
    func toggleLikeFitSite(articleId: Int)->Single<LikeFitSiteDTO> {
        return service.toggleLikeFitSite(articleId: articleId)
    }
    
    func scrapFitSite(articleId: Int)->Single<FitSiteScrapDTO> {
        return service.scrapFitSite(articleId: articleId)
    }
    
    func reportFitSite(articleId: Int)->Single<Int> {
        return service.reportFitSite(articleId: articleId)
    }
    
    func deleteFitSite(articleId: Int)->Single<Bool> {
        return service.deleteFitSite(articleId: articleId)
    }
    
    func updateArticle(articleId: Int, feedInfo: EditFitSiteModel, remainImageList: [String])->Single<Bool> {
        return service.updateArticle(articleId: articleId, feedInfo: feedInfo, remainImageList: remainImageList)
    }
}
