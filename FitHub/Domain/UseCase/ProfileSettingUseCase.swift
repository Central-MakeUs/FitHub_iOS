//
//  NickNameUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation
import RxSwift

protocol ProfileSettingUseCase {
    func duplicationNickNameCheck(_ nickName: String) -> Single<UserInfoStatus>
}
