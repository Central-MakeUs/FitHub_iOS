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

    private let registPublisher = PublishSubject<String?>()
    
    struct Input {
        let didSelectItemEvent: Observable<CategoryDTO>
        let didDeSelectItemEvent: Observable<CategoryDTO>
        let registTap: Signal<Void>
    }
    
    struct Output {
        let registPublisher: PublishSubject<String?>
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
            .flatMap { _ in
                self.usecase.signUpWithPhoneNumber().asObservable()
                    .catch { error in
                        self.registPublisher.onNext(nil)
                        return Observable.empty() // 에러를 무시하고 빈 Observable을 반환
                    }
            }
            .subscribe(onNext: { res in
                self.registPublisher.onNext(res.nickname)
                KeychainManager.create(key: "accessToken", value: res.accessToken)
                KeychainManager.create(key: "userId", value: String(res.userId))
            })
            .disposed(by: disposeBag)

        return Output(registPublisher: registPublisher.asObserver(),
                      registButtonEnable: self.usecase.selectedIds.map { !$0.isEmpty },
                      sports: self.usecase.sports)
    }
}

