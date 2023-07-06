//
//  ProfileSettingViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import UIKit
import RxCocoa
import RxSwift

class ProfileSettingViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    let userInfo: BehaviorRelay<RegistUserInfo>
    
    let profileImage = BehaviorRelay(value: UIImage(named: "DefaultProfile"))
    
    struct Input {
        let nickNameText: Observable<String>
        let nextTap: Signal<Void>
    }
    
    struct Output {
        let nextButtonEnable: Observable<Bool>
        let nextTap: Signal<Void>
        let nickNameText: Observable<String>
        let nickNameStatus: Observable<UserInfoStatus>
    }
    
    init(_ userInfo: BehaviorRelay<RegistUserInfo>) {
        self.userInfo = userInfo
    }
    
    func transform(input: Input) -> Output {
        let nickNameText = input.nickNameText
            .distinctUntilChanged()
            .map { String($0.prefix(10)) }
        
        let nextButtonEnable = nickNameText
            .map { $0.count > 0 }
        
        let nickNameStatus = nickNameText
            .map { self.verifyNickName($0) }
        
        return Output(nextButtonEnable: nextButtonEnable,
                      nextTap: input.nextTap,
                      nickNameText: nickNameText,
                      nickNameStatus: nickNameStatus)
    }
}

extension ProfileSettingViewModel {
    //TODO: 닉네임 중복여부 체크
    private func verifyNickName(_ nickName: String) -> UserInfoStatus {
        if nickName.count <= 0 || nickName.count > 10 {
            return .nickNameOK
        }
        
        return .nickNameSuccess
    }
}
