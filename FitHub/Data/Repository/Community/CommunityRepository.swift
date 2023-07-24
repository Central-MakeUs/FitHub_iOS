//
//  CommunityRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation
import RxSwift

protocol CommunityRepositoryInterface {
    func fetchCategory() -> Single<[CategoryDTO]>
}

final class CommunityRepository: CommunityRepositoryInterface {
    private let authService: AuthService
    
    init(_ authService: AuthService) {
        self.authService = authService
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return self.authService.fetchCategory()
    }
}
