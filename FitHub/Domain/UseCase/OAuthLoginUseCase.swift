//
//  LoginUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import RxSwift
import Foundation

protocol OAuthLoginUseCase {
    func signInWithApple(_ token: String) -> Single<String>
}
