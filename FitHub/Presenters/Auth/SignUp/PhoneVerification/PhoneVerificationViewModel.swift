//
//  PhoneVerificationViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/04.
//

import Foundation
import RxSwift
import RxCocoa

class PhoneVerificationViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    let usecase: PhoneVerificationUseCase
    
    private let authNumberPublisher = PublishSubject<Result<Int,AuthError>>()
    
    struct Input {
        let authenticationNumber: Observable<String>
        let resendTap: Signal<Void>
        let nextTap: Signal<Void>
    }
    
    struct Output {
        let nextButtonEnable: Observable<Bool>
        let authNumber: Observable<String>
        let resendTap: Signal<Void>
        let authNumberPublisher: PublishSubject<Result<Int,AuthError>>
        let time: Observable<Int>
    }
    
    init(_ usecase: PhoneVerificationUseCase) {
        self.usecase = usecase
        
        self.usecase.sendAuthenticationNumber()
    }
    
    func transform(input: Input) -> Output {
        let authNumber = input.authenticationNumber
            .map { String($0.prefix(6)) }
        
        let nextButtonEnable = Observable.combineLatest(authNumber,
                                                        usecase.authenticationTime)
            .map { $0.count == 6 && $1 > 0 }
        
        input.resendTap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.usecase.sendAuthenticationNumber()
            })
            .disposed(by: disposeBag)
        
        input.nextTap.asObservable()
            .compactMap { self.usecase.registUserInfo?.phoneNumber }
            .withLatestFrom(authNumber.compactMap { Int($0) }) { ($0,$1) }
            .flatMap { self.usecase.verifyAuthenticationNumber($0, $1).asObservable() }
            .subscribe(onNext: { [weak self] code in
                self?.authNumberPublisher.onNext(.success(code))
            })
            .disposed(by: disposeBag)
        
        
        return Output(nextButtonEnable: nextButtonEnable,
                      authNumber: authNumber,
                      resendTap: input.resendTap,
                      authNumberPublisher: authNumberPublisher,
                      time: self.usecase.authenticationTime)
    }
}
