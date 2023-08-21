//
//  EditFitSiteUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/21.
//

import Foundation
import RxSwift

protocol EditFitSiteUseCaseProtocol {
    func fetchCategory() -> Single<[CategoryDTO]>
    func updateArticle(articleId: Int, feedInfo: EditFitSiteModel, remainImageList: [String])->Single<Bool>
}

final class EditFitSiteUseCase: EditFitSiteUseCaseProtocol {
    private let fitSiteRepo: FitSiteRepositoryInterface
    private let userRepo: UserRepositoryInterface
    
    init(fitSiteRepo: FitSiteRepositoryInterface,
         userRepo: UserRepositoryInterface) {
        self.fitSiteRepo = fitSiteRepo
        self.userRepo = userRepo
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return userRepo.fetchCategory()
    }
    
    func updateArticle(articleId: Int, feedInfo: EditFitSiteModel, remainImageList: [String])->Single<Bool> {
        return fitSiteRepo.updateArticle(articleId: articleId, feedInfo: feedInfo, remainImageList: remainImageList)
    }
}
