//
//  BookMarkUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation
import RxSwift

protocol BookMarkUseCaseProtocol {
    func fetchBookMark(categoryId: Int, page: Int)->Single<BookMarkDTO>
    
    func fetchCategory()->Single<[CategoryDTO]>
}

final class BookMarkUseCase: BookMarkUseCaseProtocol {
    private let homeRepository: HomeRepositoryInterface
    private let communityRepository: CommunityRepositoryInterface
    
    init(homeRepository: HomeRepositoryInterface,
         communityRepository: CommunityRepositoryInterface) {
        self.homeRepository = homeRepository
        self.communityRepository = communityRepository        
    }
    
    func fetchCategory()-> Single<[CategoryDTO]> {
        return communityRepository.fetchCategory()
            .map { [CategoryDTO(createdAt: nil, updatedAt: nil, imageUrl: nil, name: "전체", id: 0)] + $0 }
    }
    
    func fetchBookMark(categoryId: Int, page: Int)->Single<BookMarkDTO> {
        return homeRepository.fetchBookMark(categoryId: categoryId, page: page)
    }
}
