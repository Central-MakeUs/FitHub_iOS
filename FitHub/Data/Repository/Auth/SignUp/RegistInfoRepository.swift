//
//  RegistInfoRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/05.
//

import Foundation
import RxSwift

protocol RegistInfoRepositoryInterface {
    func checkRegist(phoneNum: String, type: Int) -> Single<Int>
}

class RegistInfoRepository: RegistInfoRepositoryInterface {
    private let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    func checkRegist(phoneNum: String, type: Int) -> Single<Int> {
        return self.service.checkUserInfo(phoneNum, type: type)
    }
}
