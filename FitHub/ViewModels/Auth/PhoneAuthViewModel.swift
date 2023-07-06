//
//  PhoneAuthViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//

import Foundation
import RxSwift
import RxCocoa

class PhoneAuthViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    struct Input {
        let phoneNumberText: Observable<String>
        let passwordText: Observable<String>
        let loginButtonTap: Signal<Void>
        let registButtonTap: Signal<Void>
        let findPasswordButtonTap: Signal<Void>
    }
    
    struct Output {
        let loginTap: Signal<Void>
        let loginEnable: Observable<Bool>
        let registTap: Signal<Void>
        let findPasswordTap: Signal<Void>
    }
    
    func transform(input: Input) -> Output {
        let loginEnable = Observable.combineLatest(input.phoneNumberText,
                                                   input.passwordText)
            .map { self.verifyPhoneNumber($0) && $1.count > 0 }
        
        
        return Output(loginTap: input.loginButtonTap,
                      loginEnable: loginEnable,
                      registTap: input.registButtonTap,
                      findPasswordTap: input.findPasswordButtonTap)
    }
    
    init() {
        
    }
    
    private func verifyPhoneNumber(_ numberStr: String) -> Bool {
        let phoneNumberRegex = "^010\\d{8}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: numberStr)
        return isValid
    }
}
