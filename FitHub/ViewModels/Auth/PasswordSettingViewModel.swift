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
    
    init(_ userInfo: BehaviorRelay<RegistUserInfo>) {
        self.userInfo = userInfo
    }
    
    func transform(input: Input) -> Output {
        let passwordStatus = input.passwordInput
            .distinctUntilChanged()
            .map { self.verifyPassword($0) }
        
        let passwordVerificationStatus = Observable.combineLatest(input.passwordInput, input.passwordVerificationInput)
            .distinctUntilChanged { $0.1 == $1.1 }
            .map { self.verifyPasswordVerification($0,$1) }
        
        let nextButtonEnable = Observable.combineLatest(passwordStatus, passwordVerificationStatus)
            .map { $0.0 == .passwordSuccess && $0.1 == .matchPassword }
        
        return Output(passwordStatus: passwordStatus,
                      passwordVerificationStatus: passwordVerificationStatus,
                      nextButtonEnable: nextButtonEnable,
                      nextTap: input.nextTap)
    }
}

extension PasswordSettingViewModel {
    private func verifyPassword(_ password: String) -> UserInfoStatus {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d|.*[^A-Za-z0-9]).+$"
        
        if password.count == 0 {
            return .passwordOK
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password) {
            return .notValidPassword
        }
        
        if password.count < 8 || password.count > 16 {
            return .passwordLengthError
        }
        
        return .passwordSuccess
    }
    
    private func verifyPasswordVerification(_ passwordVerification: String, _ password: String) -> UserInfoStatus {
        if passwordVerification.count == 0 {
            return .ok
        }
        
        if passwordVerification == password {
            return .matchPassword
        } else {
            return .notMatchPassword
        }
    }
}
