//
//  NickNameUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation
import RxSwift

protocol ProfileSettingUseCaseProtocol {
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus>
}

class ProfileSettingUseCase: ProfileSettingUseCaseProtocol {
    let repository: AuthRepositoryInterface
    
    init(repository: AuthRepositoryInterface) {
        self.repository = repository
    }
    
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus> {
        repository.duplicationNickNameCheck(nickName)
    }
}
