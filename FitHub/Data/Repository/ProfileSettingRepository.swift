//
//  ProfileSettingRepository.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation
import RxSwift

class ProfileSettingRepository: ProfileSettingUseCase {
    private let disposeBag = DisposeBag()
    
    private let service: AuthService
    
    init(_ service: AuthService = AuthService()) {
        self.service = service
    }
    
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus> {
        return self.service.duplicationNickNameCheck(nickName)
            .map { $0.code == 2011 ? .nickNameSuccess : .duplicateNickName }

    }
}
