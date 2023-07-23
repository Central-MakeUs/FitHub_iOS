//
//  AgreementViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/28.
//

import Foundation
import RxSwift
import RxCocoa

class AgreementViewModel: ViewModelType {

    var disposeBag = DisposeBag()
    
    let registUserInfo = BehaviorRelay(value: RegistUserInfo())
    
    struct Input {
        let privateTap: Observable<Void>
        let useTap: Observable<Void>
        let locationTap: Observable<Void>
        let ageTap: Observable<Void>
        let marketingTap: Observable<Void>
        let allAgreementTap: Observable<Void>
    }
    
    struct Output {
        let privateAgreement = BehaviorRelay(value: false)

        let useAgreement = BehaviorRelay(value: false)

        let locationAgreement = BehaviorRelay(value: false)

        let ageAgreement = BehaviorRelay(value: false)

        let marketingAgreement = BehaviorRelay(value: false)

        let allAgreement = BehaviorRelay(value: false)

        let isEnableNextButton = BehaviorRelay(value: false)
    }
    
    init() {
        
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.ageTap
            .withLatestFrom(output.ageAgreement)
            .map { !$0 }
            .bind(to: output.ageAgreement)
            .disposed(by: disposeBag)
        
        input.useTap
            .withLatestFrom(output.useAgreement)
            .map { !$0 }
            .bind(to: output.useAgreement)
            .disposed(by: disposeBag)
        
        input.locationTap
            .withLatestFrom(output.locationAgreement)
            .map { !$0 }
            .bind(to: output.locationAgreement)
            .disposed(by: disposeBag)
        
        input.privateTap
            .withLatestFrom(output.privateAgreement)
            .map { !$0 }
            .bind(to: output.privateAgreement)
            .disposed(by: disposeBag)
        
        input.marketingTap
            .withLatestFrom(output.marketingAgreement)
            .map { !$0 }
            .bind(to: output.marketingAgreement)
            .disposed(by: disposeBag)
        
        input.allAgreementTap
            .withLatestFrom(output.allAgreement)
            .map { !$0 }
            .subscribe(onNext: {
                output.privateAgreement.accept($0)
                output.useAgreement.accept($0)
                output.locationAgreement.accept($0)
                output.ageAgreement.accept($0)
                output.marketingAgreement.accept($0)
            })
            .disposed(by: disposeBag)
        
        output.marketingAgreement
            .map { RegistUserInfo(marketingAgree: $0) }
            .bind(to: self.registUserInfo)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.privateAgreement,
                                 output.useAgreement,
                                 output.locationAgreement,
                                 output.ageAgreement)
            .map { $0.0 && $0.1 && $0.2 && $0.3}
            .bind(to: output.isEnableNextButton)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.privateAgreement,
                                 output.useAgreement,
                                 output.locationAgreement,
                                 output.ageAgreement,
                                 output.marketingAgreement)
            .map { $0.0 && $0.1 && $0.2 && $0.3 && $0.4}
            .bind(to: output.allAgreement)
            .disposed(by: disposeBag)
        
        return output
    }
}
