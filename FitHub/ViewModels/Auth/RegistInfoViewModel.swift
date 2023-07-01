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
    
    struct Input {
        let phoneTextFieldDidEditEvent: Observable<String>
        let telecomDidSelectEvent: Observable<String>
        let dateOfBirthTextFieldDidEditEvent: Observable<String>
        let sexNumberTextFieldDidEditEvent: Observable<String>
        let nameTextFieldDidEditEvent: Observable<String>
        let nextButtonTapEvent: Observable<Int>
    }
    
    struct Output {
        let dateOfBirth: Observable<(String,Bool)>
        let sexNumber: Observable<(String,Bool)>
        let dateOfBirthStatus: Observable<UserInfoStatus>
        let telecom: Observable<TelecomProviderType>
        let nextButtonTapEvent: Observable<Int>
        let phoneNumber: Observable<(String,UserInfoStatus)>
        let nextButtonEnable: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let dateOfBirth = input.dateOfBirthTextFieldDidEditEvent
            .distinctUntilChanged()
            .map { (String($0.prefix(6)), $0.count >= 6) }
            
        let sexNumber = input.sexNumberTextFieldDidEditEvent
            .distinctUntilChanged()
            .map { (String($0.prefix(1)), $0.count >= 1) }
        
        let dateOfBirthStatus = Observable.combineLatest(dateOfBirth, sexNumber)
            .map { self.verifyDateOfBirth($0.0, sexNumStr: $1.0) }
        
        let telecom = input.telecomDidSelectEvent
            .compactMap { TelecomProviderType(rawValue: $0) }
        
        input.nextButtonTapEvent
            .bind(to: stackViewCount)
            .disposed(by: disposeBag)
        
        let phoneNumber = input.phoneTextFieldDidEditEvent
            .map { ($0, self.verifyPhoneNumber($0)) }
        
        let nextButtonEnable = Observable.combineLatest(stackViewCount, dateOfBirth, sexNumber, phoneNumber)
            .map { (stackCnt: $0, dateOfBirth: $1.1, sexNumber:$2.1, phoneNumber: $3.1 == .ok) }
            .map {
                switch $0.stackCnt {
                case 0: return $0.phoneNumber
                case 1: return $0.phoneNumber
                case 2: fallthrough
                case 3: fallthrough
                case 4: return $0.dateOfBirth && $0.sexNumber && $0.phoneNumber
                default: return false
                }
            }
        
//        Observable.combineLatest(dateOfBirth, sexNumber, telecom, name, phoneNumber)
//            .map { (dateOfBirth, sexNumber, telecom, name, phoneNumber) in
//                RegistUserInfo(phoneNumber: phoneNumber,
//                               dateOfBirth: dateOfBirth.0,
//                               sexNumber: sexNumber.0,
//                               name: name,
//                               telecom: telecom)
//            }
//            .bind(to: userInfo)
//            .disposed(by: disposeBag)
            
        return Output(dateOfBirth: dateOfBirth,
                      sexNumber: sexNumber,
                      dateOfBirthStatus: dateOfBirthStatus,
                      telecom: telecom,
                      nextButtonTapEvent: input.nextButtonTapEvent,
                      phoneNumber: phoneNumber,
                      nextButtonEnable: nextButtonEnable
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
