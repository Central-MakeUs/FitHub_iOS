//
//  MyFeedUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/19.
//

import Foundation
import RxSwift

protocol MyFeedUseCaseProtocol {
    func fetchCertificationFeed(categoryId: Int, page: Int) -> Single<CertificationFeedDTO>
    func fetchFitSiteFeed(categoryId: Int, page: Int) -> Single<FitSiteFeedDTO>
    func fetchCategory()->Single<[CategoryDTO]>
    func deleteCertifications(recordIdList: [Int])->Single<CertificationDeleteRecordsDTO>
    func deleteFitSites(articleIdList: [Int])->Single<DeleteFitSitesDTO>
}

final class MyFeedUseCase: MyFeedUseCaseProtocol {
    private let communityRepo: CommunityRepositoryInterface
    private let mypageRepo: MyPageRepositoryInterface
    
    init(communityRepo: CommunityRepositoryInterface,
         mypageRepo: MyPageRepositoryInterface) {
        self.communityRepo = communityRepo
        self.mypageRepo = mypageRepo
    }
    
    func fetchCategory()->Single<[CategoryDTO]> {
        return communityRepo.fetchCategory()
            .map { [CategoryDTO(createdAt: nil, updatedAt: nil, imageUrl: nil, name: "전체", id: 0)] + $0 }
    }
    
    func fetchCertificationFeed(categoryId: Int, page: Int) -> Single<CertificationFeedDTO> {
        return mypageRepo.fetchCertificationFeed(categoryId: categoryId, page: page)
    }
    
    func fetchFitSiteFeed(categoryId: Int, page: Int) -> Single<FitSiteFeedDTO> {
        return mypageRepo.fetchFitSiteFeed(categoryId: categoryId, page: page)
    }
    
    func deleteCertifications(recordIdList: [Int])->Single<CertificationDeleteRecordsDTO> {
        return communityRepo.deleteCertifications(recordIdList: recordIdList)
    }
    
    func deleteFitSites(articleIdList: [Int]) -> Single<DeleteFitSitesDTO> {
        return communityRepo.deleteFitSites(articleIdList: articleIdList)
    }
}
