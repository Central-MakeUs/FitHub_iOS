//
//  FindPWRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import Foundation
import RxSwift

protocol FindPWRepositoryInterface {
    func checkUserInfo(_ phoneNum: String, type: Int) -> Single<Int>
}

final class FindPWRepository: FindPWRepositoryInterface {
    private let service: UserService
    
    init(_ service: UserService) {
        self.service = service
    }
    
    func checkUserInfo(_ phoneNum: String, type: Int) -> Single<Int> {
        return service.checkUserInfo(phoneNum, type: type)
    }
}
