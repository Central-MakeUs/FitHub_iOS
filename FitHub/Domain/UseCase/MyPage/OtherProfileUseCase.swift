//
//  OtherProfileUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import Foundation
import RxSwift

protocol OtherProfileUseCaseProtocol {
    func fetchCategory()->Single<[CategoryDTO]>
    func fetchOtherProfileInfo(userId: Int) -> Single<BaseResponse<OtherUserInfoDTO>>
    func fetchOtherUserArticle(userId: Int, categoryId: Int, page: Int) -> Single<FitSiteFeedDTO>
    func reportUser(userId: Int) -> Single<Int>
}

final class OtherProfileUseCase: OtherProfileUseCaseProtocol {
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
    
    func fetchOtherProfileInfo(userId: Int) -> Single<BaseResponse<OtherUserInfoDTO>> {
        return mypageRepo.fetchOtherProfileInfo(userId: userId)
    }
    
    func fetchOtherUserArticle(userId: Int, categoryId: Int, page: Int) -> Single<FitSiteFeedDTO> {
        return mypageRepo.fetchOtherUserArticle(userId: userId, categoryId: categoryId, page: page)
    }
    
    func reportUser(userId: Int) -> Single<Int> {
        return communityRepo.reportUser(userId: userId)
    }
}
