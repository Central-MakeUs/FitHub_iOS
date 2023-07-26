//
//  SportsSelectingRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/26.
//

import Foundation
import RxSwift

protocol SportsSelectingRepositoryInterface {
    func fetchCategory() -> Single<[CategoryDTO]>
}

final class SportsSelectingRepository: SportsSelectingRepositoryInterface {
    private let service: AuthService
    
    init(_ service: AuthService) {
        self.service = service
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return self.service.fetchCategory()
    }
}
