//
//  FindPWViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation
import RxSwift

class FindPWViewModel: ViewModelType {
    private let usecase: FindPWUseCaseProtocol
    
    var disposeBag = DisposeBag()
    
    private let checkUserInfo = PublishSubject<Result<Int,AuthError>>()
    
    struct Input {
        let phoneNumber: Observable<String>
        let sendButtonTap: Observable<Void>
    }
    
    struct Output {
        let phoneNumber: Observable<String>
        let phoneStatus: Observable<(String, UserInfoStatus)>
        let sendButtonEnabled: Observable<Bool>
        let checkUserInfo: PublishSubject<Result<Int,AuthError>>
    }
    
    init(_ usecase: FindPWUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let phoneNumber = input.phoneNumber.map { String($0.prefix(11)) }
        
        let phoneStatus = phoneNumber
            .distinctUntilChanged()
            .map { ($0, self.usecase.verifyPhoneNumber($0)) }
        
        let sendButtonEnabled = phoneStatus
            .map { $0.count == 11 && $1 == .ok }
        
        input.sendButtonTap
            .withLatestFrom(phoneNumber)
            .flatMap { self.usecase.checkUserInfo($0).asObservable() }
            .subscribe(onNext: { [weak self] code in
                self?.checkUserInfo.onNext(.success(code))
            }, onError: { [weak self] error in
                self?.checkUserInfo.onNext(.failure(error as! AuthError))
            })
            .disposed(by: disposeBag)
        
        return Output(phoneNumber: phoneNumber,
                      phoneStatus: phoneStatus,
                      sendButtonEnabled: sendButtonEnabled,
                      checkUserInfo: checkUserInfo)
    }
    
}
