//
//  AgreementViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/28.
//

import Foundation
import RxSwift
import RxCocoa

class AgreementViewModel {
    let disposeBag = DisposeBag()
    
    let privateAgreementObserver = BehaviorRelay(value: false)

    let useAgreementObserver = BehaviorRelay(value: false)

    let locationAgreementObserver = BehaviorRelay(value: false)

    let ageAgreementObserver = BehaviorRelay(value: false)

    let marketingAgreementOberver = BehaviorRelay(value: false)

    let allAgreementObserver = BehaviorRelay(value: false)

    let isEnableNextButton = BehaviorRelay(value: false)
    
    init() {
        Observable.combineLatest(privateAgreementObserver, useAgreementObserver, locationAgreementObserver, ageAgreementObserver, marketingAgreementOberver)
            .map { $0.0 && $0.1 && $0.2 && $0.3}
            .bind(to: isEnableNextButton)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(privateAgreementObserver, useAgreementObserver, locationAgreementObserver, ageAgreementObserver, marketingAgreementOberver)
            .map { $0.0 && $0.1 && $0.2 && $0.3 && $0.4}
            .bind(to: allAgreementObserver)
            .disposed(by: disposeBag)
    }
    
    func toggleAllCheck(_ shouldCheck: Bool) {
        self.privateAgreementObserver.accept(shouldCheck)
        self.useAgreementObserver.accept(shouldCheck)
        self.locationAgreementObserver.accept(shouldCheck)
        self.ageAgreementObserver.accept(shouldCheck)
        self.marketingAgreementOberver.accept(shouldCheck)
    }
}
