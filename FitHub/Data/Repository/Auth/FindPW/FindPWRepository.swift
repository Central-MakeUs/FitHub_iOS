//
//  FindPWRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import Foundation
import RxSwift

protocol FindPWRepositoryInterface {
    func checkUserInfo(_ phoneNum: String) -> Single<Int>
}

final class FindPWRepository: FindPWRepositoryInterface {
    private let service: AuthService
    
    init(_ service: AuthService) {
        self.service = service
    }
    
    func checkUserInfo(_ phoneNum: String) -> Single<Int> {
        return service.checkUserInfo(phoneNum)
    }
}
