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
}

final class HomeRepository: HomeRepositoryInterface {
    private let homeService: HomeService
    private let authService: AuthService
    
    init(homeService: HomeService,
         authService: AuthService) {
        self.homeService = homeService
        self.authService = authService
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return authService.fetchCategory()
    }
    
    func fetchHomeInfo() -> Single<HomeInfoDTO> {
        return homeService.fetchHomeInfo()
    }
}
