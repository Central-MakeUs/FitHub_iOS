//
//  AgreementUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation

protocol AgreementUseCaseProtocol {
    var registUserInfo: AuthUserInfo { get set }
}

final class AgreementUseCase: AgreementUseCaseProtocol {
    var registUserInfo: AuthUserInfo = AuthUserInfo()
}
