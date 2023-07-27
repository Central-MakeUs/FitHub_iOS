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
    
    private let usecase: PhoneNumLoginUseCase
    
    private let loginPublisher = PublishSubject<Result<Void,AuthError>>()
    
    struct Input {
        let phoneNumberText: Observable<String>
        let passwordText: Observable<String>
        let loginButtonTap: Signal<Void>
        let registButtonTap: Signal<Void>
        let findPasswordButtonTap: Signal<Void>
    }
    
    struct Output {
        let loginPublisher: PublishSubject<Result<Void,AuthError>>
        let loginEnable: Observable<Bool>
        let registTap: Signal<Void>
        let findPasswordTap: Signal<Void>
        let phoneNumberText: Observable<(String,UserInfoStatus)>
    }
    
    func transform(input: Input) -> Output {
        let phoneNum = input.phoneNumberText
            .map { String($0.prefix(11)) }
            .map { ($0, self.usecase.verifyPhoneNumber($0)) }
        
        let loginEnable = Observable.combineLatest(phoneNum,
                                                   input.passwordText)
            .map { $0.1 == .ok && $1.count > 0 }
        
        input.loginButtonTap.asObservable()
            .withLatestFrom(phoneNum)
            .withLatestFrom(input.passwordText, resultSelector: { ($0.0,$1) })
            .subscribe(onNext: { [weak self] (phoneNum, password) in
                self?.signInWithPhoneNumber(phoneNum, password)
            })
            .disposed(by: disposeBag)
        
        return Output(loginPublisher: loginPublisher,
                      loginEnable: loginEnable,
                      registTap: input.registButtonTap,
                      findPasswordTap: input.findPasswordButtonTap,
                      phoneNumberText: phoneNum
        )
    }
    
    init(_ usecase: PhoneNumLoginUseCase) {
        self.usecase = usecase
    }
    
    private func signInWithPhoneNumber(_ phoneNum: String, _ password: String) {
        self.usecase.signInWithPhoneNumber(phoneNum, password)
            .subscribe(onSuccess: { response in
                //TODO: JWT 및 id 저장해두기
                print(response.accessToken)
                print(response.userId)
                self.loginPublisher.onNext(.success(()))
            }, onFailure: { error in
                print("이거?")
                self.loginPublisher.onNext(.failure(error as! AuthError))
            })
            .disposed(by: disposeBag)
    }
}
