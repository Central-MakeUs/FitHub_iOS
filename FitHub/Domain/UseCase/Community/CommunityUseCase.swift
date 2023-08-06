//
//  CommunityUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol CommunityUseCaseProtocol {
    var currentOrder: OrderType { get set }
    var currentCommunityType: CommunityType { get set }
    
    var currentId: BehaviorSubject<Int> { get set }
    var category: BehaviorSubject<[CategoryDTO]> { get set }
    var recordList: BehaviorSubject<[CertificationItem]> { get set }
    var selectedId: BehaviorRelay<Int> { get set }
    
    func fetchCertificationFeed()
}

final class CommunityUseCase: CommunityUseCaseProtocol {
    private let disposeBag = DisposeBag()
    private let repository: CommunityRepositoryInterface
    
    var selectedId = BehaviorRelay<Int>(value: 0)
    var recordList = BehaviorSubject<[CertificationItem]>(value: [])
    var category = BehaviorSubject<[CategoryDTO]>(value: [])
    var currentId = BehaviorSubject<Int>(value: 0)
    
    var currentPage = 0
    var currentOrder: OrderType = .recent
    var currentCommunityType: CommunityType = .certification
    
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
    
    func fetchCertificationFeed() {
        self.repository
            .fetchCertificationFeed(self.selectedId.value, pageIndex: currentPage, type: currentOrder)
            .subscribe(onSuccess: { [weak self] response in
                self?.recordList.onNext(response.recordList)
            })
            .disposed(by: disposeBag)
            
    }
}
