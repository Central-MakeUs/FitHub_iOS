//
//  ResetPWViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/19.
//

import Foundation
import RxSwift
import RxCocoa

final class ResetPWViewModel: ViewModelType {

    var disposeBag = DisposeBag()
    private let usecase: ResetPWUseCaseProtocol
    
    struct Input {
        let passwordInput: Observable<String>
        let passwordVerificationInput: Observable<String>
        let nextTap: Observable<Void>
    }
    
    struct Output {
        let passwordStatus: Observable<UserInfoStatus>
        let passwordVerificationStatus: Observable<UserInfoStatus>
        let nextButtonEnable: Observable<Bool>
        let changePasswordPublisher: PublishSubject<Bool>
    }
    
    init(usecase: ResetPWUseCaseProtocol) {
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
        
        input.nextTap.asObservable()
            .withLatestFrom(input.passwordInput)
            .flatMap { self.usecase.changePassword(newPassword: $0).asObservable() }
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
    
    func confirmPassword(password: String) {
        usecase.checkPassword(password: password)
            .subscribe(onSuccess: { [weak self] isSuccess in
                self?.confirmPWHandler.onNext(isSuccess)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Output
    let confirmPWHandler = PublishSubject<Bool>()
    private let changePasswordPublisher = PublishSubject<Bool>()
}

