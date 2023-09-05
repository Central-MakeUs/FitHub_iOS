//
//  OAuthRegistInputViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation
import RxSwift

final class OAuthRegistInputViewModel: ViewModelType {
    var usecase: OAuthRegistInputUseCaseProtocol
    var disposeBag = DisposeBag()
    
    var registType: RegistType = .OAuth
    
    struct Input {
        let name: Observable<String>
        let dateNumber: Observable<String>
        let gender: Observable<String>
        let nextTap: Observable<Void>
    }
    
    struct Output {
        let nextButtonEnable = BehaviorSubject<Bool>(value: false)
        let nextTap = PublishSubject<Void>()
        let dateOfBirth: Observable<(String,Bool)>
        let sexNumber: Observable<(String,Bool)>
        let dateOfBirthStatus: Observable<(UserInfoStatus,Bool)>
    }
    
    init(_ usecase: OAuthRegistInputUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let dateOfBirth = input.dateNumber
            .distinctUntilChanged()
            .map { (String($0.prefix(6)), $0.count >= 6) }
            
        let sexNumber = input.gender
            .distinctUntilChanged()
            .map { (String($0.prefix(1)), $0.count >= 1) }
        
        let dateOfBirthStatus = Observable.combineLatest(dateOfBirth, sexNumber)
            .map { (self.usecase.verifyDateOfBirth($0.0, sexNumStr: $1.0), $0.1 && $1.1) }
        
        let output = Output(dateOfBirth: dateOfBirth,
                            sexNumber: sexNumber,
                            dateOfBirthStatus: dateOfBirthStatus)
        
        let name = input.name
        
        Observable.combineLatest(name, dateOfBirth, sexNumber, dateOfBirthStatus)
            .map { (name: $0.count > 0, dateOfBirth: $1.1, sexNumber:$2.1, dateOfBirthStatus: $3.0) }
            .map { $0 && $1 && $2 && $3 == .ok}
            .subscribe(output.nextButtonEnable)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(name, dateOfBirth, sexNumber)
            .map { (name: $0, dateOfBirth: $1.0, sexNumber:$2.0) }
            .subscribe(onNext: { userInfo in
                self.usecase.registUserInfo.name = userInfo.name
                self.usecase.registUserInfo.dateOfBirth = userInfo.dateOfBirth
                self.usecase.registUserInfo.sexNumber = userInfo.sexNumber
            })
            .disposed(by: disposeBag)
        
        input.nextTap
            .bind(to: output.nextTap)
            .disposed(by: disposeBag)
        
        return output
    }
}
