//
//  HomeRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/03.
//

import Foundation
import RxSwift

protocol HomeRepositoryInterface {
    func fetchCategory() -> Single<[CategoryDTO]>
    func fetchHomeInfo() -> Single<HomeInfoDTO>
    func checkAuth() -> Single<Bool>
    func fetchLevelInfo() -> Single<LevelInfoDTO>
    func fetchBookMark(categoryId: Int, page: Int) -> Single<BookMarkDTO>
    func fetchTermList() -> Single<TermsListDTO>
}

final class HomeRepository: HomeRepositoryInterface {
    private let homeService: HomeService
    private let authService: UserService
    
    init(homeService: HomeService,
         authService: UserService) {
        self.homeService = homeService
        self.authService = authService
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return authService.fetchCategory()
    }
    
    func fetchHomeInfo() -> Single<HomeInfoDTO> {
        return homeService.fetchHomeInfo()
    }
    
    func checkAuth() -> Single<Bool> {
        return self.homeService.checkAuth()
    }
    
    func fetchLevelInfo() -> Single<LevelInfoDTO> {
        return homeService.fetchLevelInfo()
    }
    
    func fetchBookMark(categoryId: Int, page: Int) -> Single<BookMarkDTO> {
        return homeService.fetchBookMark(categoryId: categoryId, page: page)
    }
    
    func fetchTermList() -> Single<TermsListDTO> {
        return homeService.fetchTermList()
    }
}
