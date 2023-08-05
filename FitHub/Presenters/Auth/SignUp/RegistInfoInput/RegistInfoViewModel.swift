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
    
    var usecase: RegistInfoUseCaseProtocol
    
    private let checkRegistPublisher = PublishSubject<Result<Int,AuthError>>()
    
    let telecomProviders = Observable.of(TelecomProviderType.allCases)
    
    let selectedTelecomProvider: BehaviorRelay<TelecomProviderType?> = BehaviorRelay(value: nil)
    
    struct Input {
        let phoneTextFieldDidEditEvent: Observable<String>
        let dateOfBirthTextFieldDidEditEvent: Observable<String>
        let sexNumberTextFieldDidEditEvent: Observable<String>
        let nameTextFieldDidEditEvent: Observable<String>
        let sendButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let dateOfBirth: Observable<(String,Bool)>
        let sexNumber: Observable<(String,Bool)>
        let dateOfBirthStatus: Observable<(UserInfoStatus,Bool)>
        let telecom: Observable<TelecomProviderType>
        let name: Observable<String>
        let sendButtonTapEvent: Observable<Result<Int,AuthError>>
        let phoneNumber: Observable<(String,UserInfoStatus)>
        let sendButtonEnable: Observable<Bool>
    }
    
    init(_ usecase: RegistInfoUseCaseProtocol) {
        self.usecase = usecase
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
        
        let phoneNumber = input.phoneTextFieldDidEditEvent
            .map { (String($0.prefix(11)), self.usecase.verifyPhoneNumber($0)) }
        
        let name = input.nameTextFieldDidEditEvent
        
        let sendButtonEnable = Observable.combineLatest(name, dateOfBirth, sexNumber, phoneNumber)
            .map { (name: $0.count > 0, dateOfBirth: $1.1, sexNumber:$2.1, phoneNumber: $3.1 == .ok) }
            .map { $0 && $1 && $2 && $3 }
        
        input.sendButtonTapEvent
            .withLatestFrom(phoneNumber)
            .flatMap { self.usecase.checkRegist(phoneNum: $0.0, type: 0).asObservable() }
            .subscribe(onNext: { [weak self] code in
                self?.checkRegistPublisher.onNext(.success(code))
            }, onError: { [weak self] error in
                self?.checkRegistPublisher.onNext(.failure(error as! AuthError))
            })
            .disposed(by: disposeBag)
            
            
        
        Observable.combineLatest(name, dateOfBirth, sexNumber, phoneNumber, telecom)
            .map { AuthUserInfo(phoneNumber: $3.0, dateOfBirth: $1.0, sexNumber: $2.0, name: $0, telecom: $4) }
            .subscribe(onNext: { [weak self] info in
                self?.usecase.updateRegistUserInfo(info)
            })
            .disposed(by: disposeBag)
        
        return Output(dateOfBirth: dateOfBirth,
                      sexNumber: sexNumber,
                      dateOfBirthStatus: dateOfBirthStatus,
                      telecom: telecom,
                      name: name,
                      sendButtonTapEvent: checkRegistPublisher.asObservable(),
                      phoneNumber: phoneNumber,
                      sendButtonEnable: sendButtonEnable
        )
    }
}
