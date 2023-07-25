//
//  SportsSelectingUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/25.
//

import Foundation

protocol SportsSelectingUseCaseProtocol {
    var registUserInfo: AuthUserInfo { get set }
}

final class SportsSelectingUseCase: SportsSelectingUseCaseProtocol {
    var registUserInfo: AuthUserInfo
    
    init(_ userInfo: AuthUserInfo) {
        self.registUserInfo = userInfo
    }
}
