//
//  ResetPasswordRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation
import RxSwift

protocol ResetPasswordRepositoryInterface {
    func resetPassword(_ registUser: AuthUserInfo)-> Single<Bool>
}

final class ResetPasswordRepository: ResetPasswordRepositoryInterface {
    private let service: UserService
    
    init(service: UserService) {
        self.service = service
    }
    
    func resetPassword(_ userInfo: AuthUserInfo)-> Single<Bool> {
        return service.resetPassword(userInfo)
    }
}
