//
//  CommunityViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation
import RxSwift

class CommunityViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private let usecase: CommunityUseCaseProtocol
    
    let feedType = Observable.of(["운동인증","핏사이트"])
    
    let targetIndex = BehaviorSubject<Int>(value: 0)
    var currentCommunityType = BehaviorSubject<CommunityType>(value: .certification)
    
//    var currentId: BehaviorSubject<Int>
//    var category: BehaviorSubject<[CategoryDTO]>
//    var recordList: BehaviorSubject<[CertificationItem]>
    
    let output = Output()
    var currentCertificationPage = 0
    var currentFitStiePage = 0
    
    let selectedCategory = BehaviorSubject<Int>(value: 0)
    var certificationSortingType = BehaviorSubject<SortingType>(value: .recent)
    
    var fitStieSortingType = BehaviorSubject<SortingType>(value: .recent)
    
    struct Input {
    
    }
    
    struct Output {
        let category = BehaviorSubject<[CategoryDTO]>(value: [])
        let certificationFeedList = BehaviorSubject<[CertificationItem]>(value: [])
        let fitSiteFeedList = BehaviorSubject<[ArticleDTO]>(value: [])
        let targetIndex = PublishSubject<Int>()
        let selectedCategory = PublishSubject<Int>()
    }
    
    init(_ usecase: CommunityUseCaseProtocol) {
        self.usecase = usecase
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] response in
                self?.output.category.onNext(response)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(self.selectedCategory,
                                 self.certificationSortingType)
        .flatMap {
            self.usecase.fetchCertificationFeed(id: $0.0,
                                                page: self.currentCertificationPage,
                                                sortingType: $0.1).asObservable()
                .catch { error in
                    return Observable.empty()
                }
        }
        .subscribe(onNext: { [weak self] dto in
            guard let self else { return }
//            print(dto.recordList)
            output.certificationFeedList.onNext(dto.recordList)
        })
        .disposed(by: disposeBag)
        
        Observable.combineLatest(self.selectedCategory,
                                 self.fitStieSortingType)
        .flatMap {
            self.usecase.fetchFitSiteFeed($0.0,
                                          page: self.currentFitStiePage,
                                          type: $0.1).asObservable()
                .catch { error in
                    return Observable.empty()
                }
        }
        .subscribe(onNext: { [weak self] dto in
            guard let self else { return }
            output.fitSiteFeedList.onNext(dto.articleList)
            print(dto.articleList)
        })
        .disposed(by: disposeBag)
    }

    
    func transform(input: Input) -> Output {
        
 
        
        return output
    }
}
