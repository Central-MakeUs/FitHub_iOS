//
//  HomeUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/03.
//

import Foundation
import RxSwift

protocol HomeUseCaseProtocol {
    func fetchCategory()->Single<[CategoryDTO]>
    func fetchHomeInfo()->Single<HomeInfoDTO>
    func fetchLevelInfo() -> Single<LevelInfoDTO>
    
    func checkAuth() -> Single<Bool>
}

final class HomeUseCase: HomeUseCaseProtocol {
    private let repository: HomeRepositoryInterface

    init(repository: HomeRepositoryInterface) {
        self.repository = repository
    }
    
    func fetchHomeInfo()->Single<HomeInfoDTO> {
        return self.repository.fetchHomeInfo()
    }
    
    func fetchCategory()-> Single<[CategoryDTO]> {
        return self.repository.fetchCategory()
    }
    
    func checkAuth() -> Single<Bool> {
        return self.repository.checkAuth()
    }
    
    func fetchLevelInfo() -> Single<LevelInfoDTO> {
        return repository.fetchLevelInfo()
    }
}
