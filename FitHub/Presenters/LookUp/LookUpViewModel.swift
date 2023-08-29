//
//  LookUpViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/27.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

final class LookUpViewModel {
    private let usecase: LookUpUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    var isFirstLoad = true
    private var searchInfo = FacilitySearch(x: "0",
                                            y: "0",
                                            userX: "0",
                                            userY: "0",
                                            keyword: "",
                                            categoryId: 0)
    
    // Output
    let categories = BehaviorSubject<[CategoryDTO]>(value: [])
    let currentUserLocation = PublishSubject<MTMapPoint?>()
    let currentCenterLocation = PublishSubject<MTMapPoint?>()
    let selectedCategoryId = BehaviorRelay<Int>(value: 0)
    let searchQuery = BehaviorRelay<String>(value: "")
    let queryResult = BehaviorRelay<[FacilityDTO]>(value: [])
    
    init(usecase: LookUpUseCaseProtocol) {
        self.usecase = usecase
        
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] categories in
                self?.categories.onNext(categories)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(currentCenterLocation,
                                 currentUserLocation,
                                 searchQuery,
                                 selectedCategoryId)
        .map { FacilitySearch(x: String($0.0?.mapPointGeo().longitude ?? 0),
                              y: String($0.0?.mapPointGeo().latitude ?? 0),
                              userX: String($0.1?.mapPointGeo().longitude ?? 0),
                              userY: String($0.1?.mapPointGeo().latitude ?? 0),
                              keyword: $0.2,
                              categoryId: $0.3)}
        .bind(onNext: { [weak self] info in
            guard let self else { return }
            self.searchInfo = info
        })
        .disposed(by: disposeBag)
        
        queryResult.subscribe(onNext: { info in
            print(info.map { $0.name })
        })
        .disposed(by: disposeBag)
    }
    
    // Input
    func fetchFacilities() {
        usecase.fetchFacilities(searchInfo: searchInfo)
            .subscribe(onSuccess: { [weak self] info in
                print(info)
                self?.queryResult.accept(info.facilitiesList)
            })
            .disposed(by: disposeBag)
    }
}
