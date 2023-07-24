//
//  CommunityUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation
import RxSwift

protocol CommunityUseCaseProtocol {
    var category: BehaviorSubject<[CategoryDTO]> { get set }
    var currentOrder: OrderType { get set }
    var currentCommunityType: CommunityType { get set }
    
    func fetchCategory()
}

final class CommunityUseCase: CommunityUseCaseProtocol {
    private let disposeBag = DisposeBag()
    private let repository: CommunityRepositoryInterface
    
    var currentOrder: OrderType = .recent
    var currentCommunityType: CommunityType = .certification
    
    var category = BehaviorSubject<[CategoryDTO]>(value: [])
    
    init(_ repository: CommunityRepositoryInterface) {
        self.repository = repository
        
        self.fetchCategory()
    }
    
    func fetchCategory() {
        repository.fetchCategory()
            .subscribe(onSuccess: { [weak self] response in
                self?.category.onNext(response)
            })
            .disposed(by: disposeBag)
    }
}
