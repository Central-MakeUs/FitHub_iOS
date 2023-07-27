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
    }
    
    init(_ usecase: OAuthRegistInputUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        let dateOfBirth = input.dateNumber
            .distinctUntilChanged()
            .map { (String($0.prefix(6)), $0.count >= 6) }
            
        let sexNumber = input.gender
            .distinctUntilChanged()
            .map { (String($0.prefix(1)), $0.count >= 1) }
        
        let dateOfBirthStatus = Observable.combineLatest(dateOfBirth, sexNumber)
            .map { (self.usecase.verifyDateOfBirth($0.0, sexNumStr: $1.0), $0.1 && $1.1) }
        
        let name = input.name
        
        Observable.combineLatest(name, dateOfBirth, sexNumber)
            .map { (name: $0.count > 0, dateOfBirth: $1.1, sexNumber:$2.1) }
            .map { $0 && $1 && $2 }
            .subscribe(output.nextButtonEnable)
            .disposed(by: disposeBag)
        
        input.nextTap
            .bind(to: output.nextTap)
            .disposed(by: disposeBag)
        
        return output
    }
}
