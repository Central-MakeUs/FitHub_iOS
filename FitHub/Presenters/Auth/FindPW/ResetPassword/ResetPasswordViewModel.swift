//
//  ResetPasswordViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation
import RxSwift
import RxCocoa

class ResetPasswordViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private var usecase: ResetPasswordUseCaseProtocol
    private let changePasswordPublisher = PublishSubject<Bool>()
    
    struct Input {
        let passwordInput: Observable<String>
        let passwordVerificationInput: Observable<String>
        let nextTap: Signal<Void>
    }
    
    struct Output {
        let passwordStatus: Observable<UserInfoStatus>
        let passwordVerificationStatus: Observable<UserInfoStatus>
        let nextButtonEnable: Observable<Bool>
        let changePasswordPublisher: PublishSubject<Bool>
    }
    
    init(_ usecase: ResetPasswordUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let passwordStatus = input.passwordInput
            .distinctUntilChanged()
            .map { self.usecase.verifyPassword($0) }
        
        let passwordVerificationStatus = Observable.combineLatest(input.passwordInput,
                                                                  input.passwordVerificationInput)
            .filter { !$1.isEmpty }
            .map { self.usecase.verifyPasswordVerification($0,$1) }
        
        let nextButtonEnable = Observable.combineLatest(passwordStatus,
                                                        passwordVerificationStatus)
            .map { $0.0 == .passwordSuccess && $0.1 == .matchPassword }
        
        nextButtonEnable
            .filter { $0 }
            .withLatestFrom(input.passwordVerificationInput)
            .subscribe(onNext: { [weak self] password in
                self?.usecase.userInfo.password = password
            })
            .disposed(by: disposeBag)
        
        input.nextTap.asObservable()
            .flatMap { self.usecase.changePassword().asObservable() }
            .catch { [weak self] _ in
                self?.changePasswordPublisher.onNext(false)
                return Observable.empty()
            }
            .subscribe(onNext: { [weak self] isSuccess in
                self?.changePasswordPublisher.onNext(isSuccess)
            })
            .disposed(by: disposeBag)
        
        
        return Output(passwordStatus: passwordStatus,
                      passwordVerificationStatus: passwordVerificationStatus,
                      nextButtonEnable: nextButtonEnable,
                      changePasswordPublisher: changePasswordPublisher)
    }
}
