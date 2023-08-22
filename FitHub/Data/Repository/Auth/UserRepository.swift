//
//  UserRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import Foundation
import RxSwift

protocol UserRepositoryInterface {
    func fetchCategory() -> Single<[CategoryDTO]>
}

final class UserRepository: UserRepositoryInterface {
    private let service: UserService
    
    init(service: UserService) {
        self.service = service
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return service.fetchCategory()
    }
}
