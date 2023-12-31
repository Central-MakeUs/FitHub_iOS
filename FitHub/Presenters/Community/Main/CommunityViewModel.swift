//
//  CommunityViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CommunityViewModel {
    var disposeBag = DisposeBag()
    private let usecase: CommunityUseCaseProtocol
    
    var isFirstViewDidAppear = true
    
    // Paging
    var isPaging = false
    var currentCertificationPage = 0
    var isLastCertification = false
    
    var currentFitSitePage = 0
    var isLastFitSite = false
    
    // MARK: - Input
    let selectedCategory = BehaviorSubject<Int>(value: 0)
    let certificationSortingType = BehaviorSubject<SortingType>(value: .recent)
    let fitStieSortingType = BehaviorSubject<SortingType>(value: .recent)
    let certificationDidScroll = PublishSubject<(CGFloat,CGFloat,CGFloat)>()
    let fitSiteDidScroll = PublishSubject<(CGFloat,CGFloat,CGFloat)>()
    let refresh = PublishSubject<Void>()
    
    // MARK: - Output
    let feedType = Observable.of(["운동인증","핏사이트"])
    let category = BehaviorSubject<[CategoryDTO]>(value: [])
    
    let certificationFeedList = BehaviorRelay<[CertificationDTO]>(value: [])
    let fitSiteFeedList = BehaviorRelay<[ArticleDTO]>(value: [])
    var communityType = BehaviorSubject<CommunityType>(value: .certification)
    let checkTodayHandler = PublishSubject<Bool>()
    let alarmCheck = PublishSubject<Bool>()
    
    init(_ usecase: CommunityUseCaseProtocol) {
        self.usecase = usecase
        
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] response in
                self?.category.onNext(response)
            })
            .disposed(by: disposeBag)

        communityType
            .filter { $0 == .certification }
            .withLatestFrom(certificationFeedList)
            .filter{ $0.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                self?.fetchCertification(isReset: true)
            })
            .disposed(by: disposeBag)
        
        communityType
            .filter { $0 == .fitSite }
            .withLatestFrom(fitSiteFeedList)
            .filter{ $0.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                self?.fetchFitSite(isReset: true)
            })
            .disposed(by: disposeBag)
        
        selectedCategory
            .distinctUntilChanged()
            .withLatestFrom(communityType)
            .subscribe(onNext: { [weak self] type in
                if type == .certification {
                    self?.resetFitSite()
                    self?.fetchCertification(isReset: true)
                } else {
                    self?.resetCertification()
                    self?.fetchFitSite(isReset: true)
                }
            })
            .disposed(by: disposeBag)
        
        fitStieSortingType
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.fetchFitSite(isReset: true)
            })
            .disposed(by: disposeBag)
        
        certificationSortingType
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.fetchCertification(isReset: true)
            })
            .disposed(by: disposeBag)

        
        didScroll()
        refreshFeed()
    }
    
    func didScroll() {
        fitSiteDidScroll
            .filter { $0.1 != 0.0 }
            .subscribe(onNext: { [weak self] (offsetY, contentHeight, frameHeight) in
                guard let self else { return }
                if offsetY > (contentHeight - frameHeight) {
                    if self.isPaging == false && !isLastFitSite { self.fitSitePaging() }
                }
            })
            .disposed(by: disposeBag)
        
        certificationDidScroll
            .filter { $0.1 != 0.0 }
            .subscribe(onNext: { [weak self] (offsetY, contentHeight, frameHeight) in
                guard let self else { return }
                if offsetY > (contentHeight - frameHeight) {
                    if self.isPaging == false && !isLastCertification { self.certifiactionPaging() }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func refreshFeed() {
        communityType.asObserver()
            .take(1)
            .subscribe(onNext: { [weak self] type in
                if type == .certification {
                    self?.fetchCertification(isReset: true)
                } else {
                    self?.fetchFitSite(isReset: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func checkToday() {
        usecase.checkHasTodayCertification()
            .subscribe(onSuccess: { [weak self] result in
                self?.checkTodayHandler.onNext(result.isWrite)
            })
            .disposed(by: disposeBag)
    }
    
    func checkAlarm() {
        usecase.checkRemainAlarm()
            .subscribe(onSuccess: { [weak self] result in
                self?.alarmCheck.onNext(result.isRemain)
            })
            .disposed(by: disposeBag)
    }
}

extension CommunityViewModel {
    private func resetFitSite() {
        self.currentFitSitePage = 0
        self.isLastFitSite = false
        self.fitSiteFeedList.accept([])
    }
    
    private func resetCertification() {
        self.currentCertificationPage = 0
        self.isLastCertification = false
        self.certificationFeedList.accept([])
    }
    
    private func fitSitePaging() {
        self.isPaging = true
        currentFitSitePage += 1
        fetchFitSite(isReset: false)
    }
    
    private func certifiactionPaging() {
        self.isPaging = true
        currentCertificationPage += 1
        fetchCertification(isReset: false)
    }
    
    private func fetchFitSite(isReset: Bool) {
        if isReset {
            self.currentFitSitePage = 0
            self.isLastFitSite = false
        }
        Observable.combineLatest(selectedCategory.asObservable(),
                                 fitStieSortingType.asObservable())
        .take(1)
        .flatMap {
            self.usecase.fetchFitSiteFeed($0.0,
                                          page: self.currentFitSitePage,
                                          type: $0.1).asObservable()
                .catch { error in
                    return Observable.empty()
                }
        }
        .subscribe(onNext: { [weak self] result in
            guard let self else { return }
            var newValue = self.fitSiteFeedList.value
            if isReset { newValue = [] }
            newValue.append(contentsOf: result.articleList)
            self.fitSiteFeedList.accept(newValue)
            self.isLastFitSite = result.isLast
        },onDisposed: { [weak self] in
            self?.isPaging = false
        })
        .disposed(by: disposeBag)
    }
    
    private func fetchCertification(isReset: Bool) {
        if isReset {
            self.currentCertificationPage = 0
            self.isLastCertification = false
        }
        Observable.combineLatest(selectedCategory.asObservable(),
                                 certificationSortingType.asObservable())
        .take(1)
        .flatMap {
            self.usecase.fetchCertificationFeed(id: $0.0,
                                                page: self.currentCertificationPage,
                                                sortingType: $0.1).asObservable()
                .catch { error in
                    return Observable.empty()
                }
        }
        .subscribe(onNext: { [weak self] result in
            guard let self else { return }
            var newValue = self.certificationFeedList.value
            if isReset { newValue = [] }
            newValue.append(contentsOf: result.recordList)
            self.certificationFeedList.accept(newValue)
            self.isLastCertification = result.isLast
        },onDisposed: { [weak self] in
            self?.isPaging = false
        })
        .disposed(by: disposeBag)
    }
}
