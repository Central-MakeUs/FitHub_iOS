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
    
    var userInfo = BehaviorRelay<RegistUserInfo>(value: RegistUserInfo())
    
    let telecomProviders = Observable.of(TelecomProviderType.allCases)
    
    let selectedTelecomProvider: BehaviorRelay<TelecomProviderType?> = BehaviorRelay(value: nil)
    
    let stackViewCount = BehaviorRelay(value: 1)
    
    let authenticationNumber = BehaviorRelay(value: "")
    
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
        let sendButtonTapEvent: Observable<Int>
        let phoneNumber: Observable<(String,UserInfoStatus)>
        let sendButtonEnable: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let dateOfBirth = input.dateOfBirthTextFieldDidEditEvent
            .distinctUntilChanged()
            .map { (String($0.prefix(6)), $0.count >= 6) }
            
        let sexNumber = input.sexNumberTextFieldDidEditEvent
            .distinctUntilChanged()
            .map { (String($0.prefix(1)), $0.count >= 1) }
        
        let dateOfBirthStatus = Observable.combineLatest(dateOfBirth, sexNumber)
            .map { (self.verifyDateOfBirth($0.0, sexNumStr: $1.0), $0.1 && $1.1)}
        
        let telecom = self.selectedTelecomProvider
            .compactMap { $0 }
        
        input.sendButtonTapEvent
            .bind(to: stackViewCount)
            .disposed(by: disposeBag)
        
        let phoneNumber = input.phoneTextFieldDidEditEvent
            .map { (String($0.prefix(11)), self.verifyPhoneNumber($0)) }
        
        let name = input.nameTextFieldDidEditEvent
        
        let sendButtonEnable = Observable.combineLatest(name, dateOfBirth, sexNumber, phoneNumber)
            .map { (name: $0.count > 0, dateOfBirth: $1.1, sexNumber:$2.1, phoneNumber: $3.1 == .ok) }
            .map { $0 && $1 && $2 && $3 }
        
        return Output(dateOfBirth: dateOfBirth,
                      sexNumber: sexNumber,
                      dateOfBirthStatus: dateOfBirthStatus,
                      telecom: telecom,
                      name: name,
                      sendButtonTapEvent: input.sendButtonTapEvent,
                      phoneNumber: phoneNumber,
                      sendButtonEnable: sendButtonEnable
        )
    }
    
    private func verifyPhoneNumber(_ numberStr: String) -> UserInfoStatus {
        let phoneNumberRegex = "^010\\d{8}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: numberStr)
        return isValid ? .ok : .notValidPhoneNumber
    }
    
    private func verifyDateOfBirth(_ dateStr: String, sexNumStr: String) -> UserInfoStatus {
        let dateRegex = "[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|[1,2][0-9]|3[0,1])"
        let sexNumRegex = "^[1-4]$"
        
        if !NSPredicate(format: "SELF MATCHES %@", dateRegex).evaluate(with: dateStr) {
            return .notValidDateOfBirth
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", sexNumRegex).evaluate(with: sexNumStr) {
            return .notValidSexNumber
        }
        
        return .ok
    }
}
