//
//  PasswordSettingViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import Foundation
import RxSwift
import RxCocoa

class PasswordSettingViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private let usecase: PasswordUseCaseProtocol
    
    let userInfo: BehaviorRelay<RegistUserInfo>
    
    struct Input {
        let passwordInput: Observable<String>
        let passwordVerificationInput: Observable<String>
        let nextTap: Signal<Void>
    }
    
    struct Output {
        let passwordStatus: Observable<UserInfoStatus>
        let passwordVerificationStatus: Observable<UserInfoStatus>
        let nextButtonEnable: Observable<Bool>
        let nextTap: Signal<Void>
    }
    
    init(_ userInfo: BehaviorRelay<RegistUserInfo>, usecase: PasswordUseCaseProtocol) {
        self.usecase = usecase
        self.userInfo = userInfo
    }
    
    func transform(input: Input) -> Output {
        let passwordStatus = input.passwordInput
            .distinctUntilChanged()
            .map { self.usecase.verifyPassword($0) }
        
        let passwordVerificationStatus = Observable.combineLatest(input.passwordInput,
                                                                  input.passwordVerificationInput)
            .distinctUntilChanged { $0.1 == $1.1 }
            .map { self.usecase.verifyPasswordVerification($0,$1) }
        
        let nextButtonEnable = Observable.combineLatest(passwordStatus,
                                                        passwordVerificationStatus)
            .map { $0.0 == .passwordSuccess && $0.1 == .matchPassword }
        
        return Output(passwordStatus: passwordStatus,
                      passwordVerificationStatus: passwordVerificationStatus,
                      nextButtonEnable: nextButtonEnable,
                      nextTap: input.nextTap)
    }
}
