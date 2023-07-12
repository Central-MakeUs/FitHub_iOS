//
//  FindPWViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation
import RxSwift

class FindPWViewModel: ViewModelType {
    private let usecase: FindPWUseCase
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let phoneNumber: Observable<String>
    }
    
    struct Output {
        let phoneNumber: Observable<String>
        let phoneStatus: Observable<(String, UserInfoStatus)>
        let sendButtonEnabled: Observable<Bool>
    }
    
    init(_ usecase: FindPWUseCase = FindPWInteractor()) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let phoneNumber = input.phoneNumber.map { String($0.prefix(11)) }
        
        let phoneStatus = phoneNumber
            .distinctUntilChanged()
            .map { ($0, self.usecase.verifyPhoneNumber($0)) }
        
        let sendButtonEnabled = phoneStatus
            .map { $0.count == 11 && $1 == .ok }
        
        return Output(phoneNumber: phoneNumber,
                      phoneStatus: phoneStatus,
                      sendButtonEnabled: sendButtonEnabled)
    }
    
}
