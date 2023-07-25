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
    
    let sports = Observable.of(["테니스","크로스핏","폴댄스","수영","스케이트","클라이밍"])
    let selectedSports: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    struct Input {
        let didSelectItemEvent: Observable<(IndexPath,String)>
        let didDeSelectItemEvent: Observable<(IndexPath,String)>
        let registTap: Signal<Void>
    }
    
    struct Output {
        let itemSelect: Observable<IndexPath>
        let itemDeselect: Observable<IndexPath>
        let registTap: Signal<Void>
    }
    
    init(_ usecase: SportsSelectingUseCase) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        Observable.combineLatest(input.didSelectItemEvent,
                                 selectedSports.asObservable())
            .distinctUntilChanged { $0.0 == $1.0 }
            .bind(onNext: {
                var newSelected = $1
                newSelected.append($0.1)
                self.selectedSports.accept(newSelected)
            })
            .disposed(by: disposeBag)
        
        return Output(itemSelect: input.didSelectItemEvent.map { $0.0 },
                      itemDeselect: input.didDeSelectItemEvent.map { $0.0 },
                      registTap: input.registTap)
    }
}
