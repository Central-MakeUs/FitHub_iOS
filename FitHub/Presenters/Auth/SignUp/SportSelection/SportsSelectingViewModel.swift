//
//  SportsSelectingViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import UIKit
import RxSwift
import RxCocoa

class SportsSelectingViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    var usecase: SportsSelectingUseCaseProtocol

    struct Input {
        let didSelectItemEvent: Observable<CategoryDTO>
        let didDeSelectItemEvent: Observable<CategoryDTO>
        let registTap: Signal<Void>
    }
    
    struct Output {
        let registTap: Signal<Void>
        let registButtonEnable: Observable<Bool>
        let sports: BehaviorSubject<[CategoryDTO]>
    }
    
    init(_ usecase: SportsSelectingUseCase) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        input.didSelectItemEvent
            .subscribe(onNext: { category in
                self.usecase.registUserInfo.preferExercise.append(category)
            })
            .disposed(by: disposeBag)
        
        input.didDeSelectItemEvent
            .subscribe(onNext: { category in
                self.usecase.registUserInfo.preferExercise.removeAll(where: { $0 == category })
            })
            .disposed(by: disposeBag)
        
        input.registTap.asObservable()
            .flatMap { self.usecase.signUpWithPhoneNumber() }
            .subscribe(onNext: { res in
                print(res.accessToken)
                print(res.userId)
                //TODO: Token/UserId 저장
            })
            .disposed(by: disposeBag)
        
        return Output(registTap: input.registTap,
                      registButtonEnable: self.usecase.selectedIds.map { !$0.isEmpty },
                      sports: self.usecase.sports)
    }
}

