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

    var userInfo: BehaviorRelay<RegistUserInfo>?
    
    struct Input {
        let authenticationNumber: Observable<String>
        let resendTap: Signal<Void>
        let nextTap: Signal<Void>
    }

    struct Output {
        let nextButtonEnable: Observable<Bool>
        let authNumber: Observable<String>
        let resendTap: Signal<Void>
        let nextTap: Signal<Void>
    }

    init(userInfo: BehaviorRelay<RegistUserInfo>) {
        self.userInfo = userInfo
    }
    
    init() {
        
    }

    func transform(input: Input) -> Output {
        let nextButtonEnable = input.authenticationNumber
            .map { String($0.prefix(6)).count == 6 }

        let authNumber = input.authenticationNumber
            .distinctUntilChanged()
            .map { String($0.prefix(6)) }
        
        return Output(nextButtonEnable: nextButtonEnable,
                      authNumber: authNumber,
                      resendTap: input.resendTap,
                      nextTap: input.nextTap
        )
    }
}
