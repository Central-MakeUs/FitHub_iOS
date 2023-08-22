//
//  NotiSettingUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import Foundation
import RxSwift

protocol NotiSettingUseCaseProtocol {
    func checkNotiSetting() -> Single<NotiSettingDTO>
    func updateNotiSetting(communityPermit: Bool, marketingPermit: Bool) -> Single<NotiSettingDTO>
}

final class NotiSettingUseCase: NotiSettingUseCaseProtocol {
    private let homeRepo: HomeRepositoryInterface
    
    init(homeRepo: HomeRepositoryInterface) {
        self.homeRepo = homeRepo
    }
    
    func checkNotiSetting() -> Single<NotiSettingDTO> {
        return homeRepo.checkNotiSetting()
    }
    
    func updateNotiSetting(communityPermit: Bool, marketingPermit: Bool) -> Single<NotiSettingDTO> {
        return homeRepo.updateNotiSetting(communityPermit: communityPermit, marketingPermit: marketingPermit)
    }
}
