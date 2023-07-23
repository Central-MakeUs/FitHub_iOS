//
//  RegistInfoViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/29.
//

import Foundation
import RxSwift
import RxCocoa

class RegistInfoViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private let usecase: RegistInfoUseCaseProtocol
    
    private let sendCodePublisher = PublishSubject<Result<Int,AuthError>>()
    
    let userInfo: BehaviorRelay<RegistUserInfo>
    
    let telecomProviders = Observable.of(TelecomProviderType.allCases)
    
    let selectedTelecomProvider: BehaviorRelay<TelecomProviderType?> = BehaviorRelay(value: nil)
    
    let stackViewCount = BehaviorRelay(value: 1)
    
    struct Input {
        let phoneTextFieldDidEditEvent: Observable<String>
        let dateOfBirthTextFieldDidEditEvent: Observable<String>
        let sexNumberTextFieldDidEditEvent: Observable<String>
        let nameTextFieldDidEditEvent: Observable<String>
        let sendButtonTapEvent: Observable<Int>
    }
    
    struct Output {
        let dateOfBirth: Observable<(String,Bool)>
        let sexNumber: Observable<(String,Bool)>
        let dateOfBirthStatus: Observable<(UserInfoStatus,Bool)>
        let telecom: Observable<TelecomProviderType>
        let name: Observable<String>
        let sendCodePublisher: PublishSubject<Result<Int,AuthError>>
        let phoneNumber: Observable<(String,UserInfoStatus)>
        let sendButtonEnable: Observable<Bool>
    }
    
    init(_ usecase: RegistInfoUseCaseProtocol, userInfo: BehaviorRelay<RegistUserInfo>) {
        self.usecase = usecase
        self.userInfo = userInfo
    }
    
    func transform(input: Input) -> Output {
        let dateOfBirth = input.dateOfBirthTextFieldDidEditEvent
            .distinctUntilChanged()
            .map { (String($0.prefix(6)), $0.count >= 6) }
            
        let sexNumber = input.sexNumberTextFieldDidEditEvent
            .distinctUntilChanged()
            .map { (String($0.prefix(1)), $0.count >= 1) }
        
        let dateOfBirthStatus = Observable.combineLatest(dateOfBirth, sexNumber)
            .map { (self.usecase.verifyDateOfBirth($0.0, sexNumStr: $1.0), $0.1 && $1.1)}
        
        let telecom = self.selectedTelecomProvider
            .compactMap { $0 }
        
        input.sendButtonTapEvent
            .bind(to: stackViewCount)
            .disposed(by: disposeBag)
        
        let phoneNumber = input.phoneTextFieldDidEditEvent
            .map { (String($0.prefix(11)), self.usecase.verifyPhoneNumber($0)) }
        
        let name = input.nameTextFieldDidEditEvent
        
        let sendButtonEnable = Observable.combineLatest(name, dateOfBirth, sexNumber, phoneNumber)
            .map { (name: $0.count > 0, dateOfBirth: $1.1, sexNumber:$2.1, phoneNumber: $3.1 == .ok) }
            .map { $0 && $1 && $2 && $3 }
        
        Observable.combineLatest(name, dateOfBirth, sexNumber, phoneNumber, telecom)
            .map { RegistUserInfo(phoneNumber: $3.0, dateOfBirth: $1.0, sexNumber: $2.0, name: $0, telecom: $4) }
            .bind(to: self.userInfo)
            .disposed(by: disposeBag)
        
        input.sendButtonTapEvent
            .withLatestFrom(phoneNumber)
            .flatMap { self.usecase.sendAuthenticationNumber($0.0).asObservable() }
            .subscribe(onNext: { [weak self] code in
                self?.sendCodePublisher.onNext(.success(code))
            }, onError: { [weak self] error in
                self?.sendCodePublisher.onNext(.failure(error as! AuthError))
            })
            
        
        return Output(dateOfBirth: dateOfBirth,
                      sexNumber: sexNumber,
                      dateOfBirthStatus: dateOfBirthStatus,
                      telecom: telecom,
                      name: name,
                      sendCodePublisher: sendCodePublisher,
                      phoneNumber: phoneNumber,
                      sendButtonEnable: sendButtonEnable
        )
    }
}
