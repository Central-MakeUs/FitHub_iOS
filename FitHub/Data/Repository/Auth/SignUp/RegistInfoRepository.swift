//
//  RegistInfoRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import Foundation
import RxSwift

//MARK: api 아직 안나옴
protocol RegistInfoRepositoryInterface {
    
}

final class RegistInfoRepository: RegistInfoRepositoryInterface {
    private let service: AuthService
    
    init(_ service: AuthService) {
        self.service = service
    }
}
