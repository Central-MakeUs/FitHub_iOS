//
//  SportsSelectingViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import UIKit
import RxSwift
import RxCocoa

final class SportsSelectingViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    var usecase: SportsSelectingUseCaseProtocol
    
    var registType: RegistType
    
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
    
    init(_ usecase: SportsSelectingUseCase,
         registType: RegistType) {
        self.registType = registType
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
            .filter { self.registType == .OAuth }
            .flatMap { _ in
                self.usecase.signUpWithOAuth().asObservable()
                    .catch { error in
                        self.registPublisher.onNext(nil)
                        return Observable.empty() // 에러를 무시하고 빈 Observable을 반환
                    }
            }
            .subscribe(onNext: { res in
                self.registPublisher.onNext(res.nickname)
                guard let accessToken = res.accessToken else { return }
                KeychainManager.create(key: "userId", value: String(res.userId))
            })
            .disposed(by: disposeBag)

        
        input.registTap.asObservable()
            .filter { self.registType == .Phone }
            .flatMap { _ in
                    self.usecase.signUpWithPhoneNumber().asObservable()
                        .catch { error in
                            self.registPublisher.onNext(nil)
                            return Observable.empty() // 에러를 무시하고 빈 Observable을 반환
                        }
            }
            .subscribe(onNext: { res in
                self.registPublisher.onNext(res.nickname)
                guard let accessToken = res.accessToken else { return }
                KeychainManager.create(key: "accessToken", value: accessToken )
                KeychainManager.create(key: "userId", value: String(res.userId))
            })
            .disposed(by: disposeBag)
        
        return Output(registPublisher: registPublisher.asObserver(),
                      registButtonEnable: self.usecase.selectedIds.map { !$0.isEmpty },
                      sports: self.usecase.sports)
    }
}
