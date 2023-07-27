//
//  PhoneVerificationUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/22.
//

import Foundation
import RxSwift

protocol PhoneVerificationUseCaseProtocol {
    var registUserInfo: AuthUserInfo? { get set }
    var authenticationCode: PublishSubject<Int> { get set }
    var authenticationTime: PublishSubject<Int> { get set }
    
    var timer: Disposable { get set }
    
    func sendAuthenticationNumber()
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int>
}

final class PhoneVerificationUseCase: PhoneVerificationUseCaseProtocol {
    var disposeBag = DisposeBag()
    
    var timer = Disposables.create()
    
    var registUserInfo: AuthUserInfo?
    var authenticationTime = PublishSubject<Int>()
    var authenticationCode = PublishSubject<Int>()
    
    private let repository: PhoneVerificationRepositoryInterface
    
    init(repository: PhoneVerificationRepositoryInterface) {
        self.repository = repository
    }
    
    deinit {
        self.timer.dispose()
    }
    
    func sendAuthenticationNumber() {
        guard let phoneNum = self.registUserInfo?.phoneNumber else { return }
        repository.sendAuthenticationNumber(phoneNum)
            .subscribe(onSuccess: { code in
                self.authenticationCode.onNext(code)
                    
                self.timer = self.createTimer().subscribe(self.authenticationTime)
            })
            .disposed(by: disposeBag)
    }
    
    func verifyAuthenticationNumber(_ phoneNum: String, _ authNum: Int) -> Single<Int> {
        return repository.verifyAuthenticationNumber(phoneNum, authNum)
    }
    
    private func createTimer() -> Observable<Int> {
        self.timer.dispose()
        
        return Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
            .map { elapsedTime in
                return 180 - elapsedTime
            }
            .filter { $0 >= 0 }
    }
}
