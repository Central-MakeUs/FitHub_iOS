//
//  FacilitySearchViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/09/02.
//

import Foundation
import RxSwift
import RxCocoa

final class FacilitySearchViewModel {
    private let usecase: LookUpUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    let searchText = BehaviorRelay<String>(value: "")
    
    // MARK: - Output
    let recommentKeywords = PublishSubject<[String]>()
    
    init(usecase: LookUpUseCaseProtocol) {
        self.usecase = usecase
        
        
        usecase.fetchRecommendFacilites()
            .subscribe(onSuccess: { [weak self] info in
                self?.recommentKeywords.onNext(info.keywordList)
            })
            .disposed(by: disposeBag)
    }
}
