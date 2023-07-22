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
    
    private let usecase: PhoneVerificationUseCase
    
    var registUserInfo: BehaviorRelay<RegistUserInfo>?
    
    var phoneNumber: BehaviorRelay<String>?
    
    private let reSendCodePublisher = PublishSubject<Result<Int,AuthError>>()
    
    private let authNumberPublisher = PublishSubject<Result<Int,AuthError>>()
    
    private let authenticationCode = BehaviorSubject<Int>(value: 0)
    
    private let authenticationTime = PublishSubject<Int>()
    
    private var timer: Disposable = Disposables.create()
    
    struct Input {
        let authenticationNumber: Observable<String>
        let resendTap: Signal<Void>
        let nextTap: Signal<Void>
    }
    
    struct Output {
        let nextButtonEnable: Observable<Bool>
        let authNumber: Observable<String>
        let resendPublisher: PublishSubject<Result<Int,AuthError>>
        let authNumberPublisher: PublishSubject<Result<Int,AuthError>>
        let time: Observable<Int>
    }
    
    init(_ usecase: PhoneVerificationUseCase, userInfo: BehaviorRelay<RegistUserInfo>) {
        self.usecase = usecase
        self.registUserInfo = userInfo
        
        guard let phoneNumber = userInfo.value.phoneNumber else { return }
        self.createCode(phoneNumber)
    }
    
    init(_ usecase: PhoneVerificationUseCase, phoneNumber: String) {
        self.usecase = usecase
        self.phoneNumber = BehaviorRelay(value: phoneNumber)
        
        self.createCode(phoneNumber)
    }
    
    deinit {
        self.timer.dispose()
    }
    
    func transform(input: Input) -> Output {
        let nextButtonEnable = Observable.combineLatest(input.authenticationNumber, self.authenticationTime)
            .map { String($0.prefix(6)).count == 6 && $1 > 0 }
        
        let authNumber = input.authenticationNumber
            .map { String($0.prefix(6)) }
        
        if let phoneNumber {
            input.resendTap.asObservable()
                .withLatestFrom(phoneNumber.asObservable())
                .flatMap { self.usecase.sendAuthenticationNumber($0).asObservable() }
                .subscribe(onNext: { [weak self] code in
                    guard let self else { return }
                    self.reSendCodePublisher.onNext(.success(code))
                    self.authenticationCode.onNext(code)
                    
                    self.timer = self.createTimer()
                        .subscribe(self.authenticationTime)
                }, onError: { [weak self] error in
                    self?.reSendCodePublisher.onNext(.failure(error as! AuthError))
                })
                .disposed(by: disposeBag)
            
            input.nextTap.asObservable()
                .withLatestFrom(phoneNumber.asObservable())
                .withLatestFrom(authNumber.compactMap { Int($0) }) { ($0,$1) }
                .flatMap { self.usecase.verifyAuthenticationNumber($0, $1).asObservable() }
                .subscribe(onNext: { [weak self] code in
                    self?.authNumberPublisher.onNext(.success(code))
                })
                .disposed(by: disposeBag)
            
        }
        
        if let registUserInfo {
            input.resendTap.asObservable()
                .withLatestFrom(registUserInfo)
                .compactMap { $0.phoneNumber }
                .flatMap { self.usecase.sendAuthenticationNumber($0).asObservable() }
                .subscribe(onNext: { [weak self] code in
                    guard let self else { return }
                    self.reSendCodePublisher.onNext(.success(code))
                    self.authenticationCode.onNext(code)
                    
                    self.timer = self.createTimer()
                        .subscribe(self.authenticationTime)
                }, onError: { [weak self] error in
                    self?.reSendCodePublisher.onNext(.failure(error as! AuthError))
                })
                .disposed(by: disposeBag)
            
            input.nextTap.asObservable()
                .withLatestFrom(registUserInfo)
                .compactMap { $0.phoneNumber }
                .withLatestFrom(authNumber.compactMap { Int($0) }) { ($0,$1) }
                .flatMap { self.usecase.verifyAuthenticationNumber($0, $1).asObservable() }
                .subscribe(onNext: { [weak self] code in
                    self?.authNumberPublisher.onNext(.success(code))
                })
                .disposed(by: disposeBag)
        }
        
        return Output(nextButtonEnable: nextButtonEnable,
                      authNumber: authNumber,
                      resendPublisher: reSendCodePublisher,
                      authNumberPublisher: authNumberPublisher,
                      time: authenticationTime
        )
    }
    
    private func createTimer() -> Observable<Int> {
        self.timer.dispose()
        
        return Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
            .map { elapsedTime in
                return 180 - elapsedTime
            }
            .filter { $0 >= 0 }
    }
    
    private func createCode(_ phoneNumber: String) {
        self.usecase.sendAuthenticationNumber(phoneNumber)
            .subscribe(onSuccess: { code in
                self.authenticationCode.onNext(code)
                
                self.timer = self.createTimer().subscribe(self.authenticationTime)
            })
            .disposed(by: disposeBag)
    }
    
}
