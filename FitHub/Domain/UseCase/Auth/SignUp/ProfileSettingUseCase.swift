//
//  NickNameUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation
import RxSwift

protocol ProfileSettingUseCaseProtocol {
    var registUserInfo: AuthUserInfo { get set }
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus>
}

class ProfileSettingUseCase: ProfileSettingUseCaseProtocol {
    var registUserInfo: AuthUserInfo
    
    let repository: ProfileRepositoryInterface
    
    init(repository: ProfileRepositoryInterface,
         userInfo: AuthUserInfo) {
        self.registUserInfo = userInfo
        self.repository = repository
    }
    
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus> {
        repository.duplicationNickNameCheck(nickName)
    }
}
