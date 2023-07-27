//
//  ResetPasswordRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation
import RxSwift

protocol ResetPasswordRepositoryInterface {
    func changePassword(_ registUser: AuthUserInfo)-> Single<Bool>
}

final class ResetPasswordRepository: ResetPasswordRepositoryInterface {
    private let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    func changePassword(_ userInfo: AuthUserInfo)-> Single<Bool> {
        return service.changePassword(userInfo)
    }
}
