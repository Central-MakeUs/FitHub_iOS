//
//  SportsSelectingUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/25.
//

import Foundation
import RxSwift

protocol SportsSelectingUseCaseProtocol {
    var registUserInfo: AuthUserInfo { get set }
    var sports: BehaviorSubject<[CategoryDTO]> { get set }
}

final class SportsSelectingUseCase: SportsSelectingUseCaseProtocol {
    private let repository: SportsSelectingRepositoryInterface
    private let disposeBag = DisposeBag()
    
    var registUserInfo: AuthUserInfo
    var sports = BehaviorSubject<[CategoryDTO]>(value: [])
    
    init(_ userInfo: AuthUserInfo,
         repository: SportsSelectingRepositoryInterface) {
        self.registUserInfo = userInfo
        self.repository = repository
        
        repository.fetchCategory()
            .subscribe(onSuccess: { categories in
                self.sports.onNext(categories)
            })
            .disposed(by: disposeBag)
    }
}
