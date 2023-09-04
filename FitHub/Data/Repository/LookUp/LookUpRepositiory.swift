//
//  LookUpRepositiory.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/27.
//

import Foundation
import RxSwift

protocol LookUpRepositioryInterface {
    func fetchCategory()->Single<[CategoryDTO]>
    func fetchFacilities(searchInfo: FacilitySearch)->Single<FacilitiesDTO>
    func fetchRecommendFacilites() -> Single<RecommendKeywordDTO>
    func fetchFacilitiesWithKeyword(searchInfo: FacilitySearch)-> Single<FacilitiesKeywordDTO>
}

final class LookUpRepositiory: LookUpRepositioryInterface {
    private let homeService: HomeService
    private let userService: UserService
    
    init(homeService: HomeService = HomeService(),
         userService: UserService = UserService()) {
        self.homeService = homeService
        self.userService = userService
    }
    
    func fetchCategory()->Single<[CategoryDTO]> {
        return userService.fetchCategory()
    }
    
    func fetchFacilities(searchInfo: FacilitySearch) -> Single<FacilitiesDTO> {
        return homeService.fetchFacilities(searchInfo: searchInfo)
    }
    
    func fetchRecommendFacilites() -> Single<RecommendKeywordDTO> {
        return homeService.fetchRecommendFacilites()
    }
    
    func fetchFacilitiesWithKeyword(searchInfo: FacilitySearch)-> Single<FacilitiesKeywordDTO> {
        return homeService.fetchFacilitiesWithKeyword(searchInfo: searchInfo)
    }
}
