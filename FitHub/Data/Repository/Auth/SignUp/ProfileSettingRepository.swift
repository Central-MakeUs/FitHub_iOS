//
//  ProfileSettingRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import Foundation
import RxSwift

protocol ProfileRepositoryInterface {
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus>
}

final class ProfileSettingRepository: ProfileRepositoryInterface {
    private let service: AuthService
    
    init(_ service: AuthService) {
        self.service = service
    }
    
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus> {
        return self.service.duplicationNickNameCheck(nickName)
            .map { $0 ? .duplicateNickName : .nickNameSuccess }
    }
}
