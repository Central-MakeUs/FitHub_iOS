//
//  MyFeedViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/19.
//

import Foundation
import RxSwift
import RxCocoa

final class MyFeedViewModel {
    var disposeBag = DisposeBag()
    private let usecase: MyFeedUseCaseProtocol
    
    var isFirstViewDidAppear = true
    
    // Paging
    var isPaging = false
    var currentCertificationPage = 0
    var isLastCertification = false
    
    var currentFitSitePage = 0
    var isLastFitSite = false
    
    // MARK: - Input
    let selectedCategory = BehaviorSubject<Int>(value: 0)
    let certificationDidScroll = PublishSubject<(CGFloat,CGFloat,CGFloat)>()
    let fitSiteDidScroll = PublishSubject<(CGFloat,CGFloat,CGFloat)>()
    
    // MARK: - Output
    let feedType = Observable.of(["운동인증","핏사이트"])
    let category = BehaviorSubject<[CategoryDTO]>(value: [])
    
    let certificationFeedList = BehaviorRelay<[CertificationDTO]>(value: [])
    let fitSiteFeedList = BehaviorRelay<[ArticleDTO]>(value: [])
    var communityType = BehaviorSubject<CommunityType>(value: .certification)
    
    let selectedRecoridIdList = BehaviorRelay<Set<Int>>(value: [])
    let certificationAllButtonCheck = BehaviorSubject<Bool>(value: false)
    
    let selectedArticleidIdList = BehaviorRelay<Set<Int>>(value: [])
    let fitSiteAllButtonCheck = BehaviorSubject<Bool>(value: false)
    
    init(_ usecase: MyFeedUseCaseProtocol) {
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
                self?.fetchFitSite(isReset: true)
                self?.fetchCertification(isReset: true)
                self?.communityType.onNext(type)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(selectedRecoridIdList,
                                 certificationFeedList)
        .map { $0.count == $1.count && !$0.isEmpty }
        .bind(to: certificationAllButtonCheck)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(selectedArticleidIdList,
                                 fitSiteFeedList)
        .map { $0.count == $1.count && !$0.isEmpty }
        .bind(to: fitSiteAllButtonCheck)
        .disposed(by: disposeBag)
        
        didScroll()
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
    
    // Toggle All Selection
    func toggleCertificationAllSelection() {
        let certificationFeedList = self.certificationFeedList.value
        
        if selectedRecoridIdList.value.count == certificationFeedList.count {
            self.selectedRecoridIdList.accept([])
        } else {
            let allIdList = Set(certificationFeedList.map { $0.recordId })
            self.selectedRecoridIdList.accept(allIdList)
        }
    }
    
    func deleteCertifications() {
        guard !selectedRecoridIdList.value.isEmpty else { return }
        usecase.deleteCertifications(recordIdList: selectedRecoridIdList.value.map { $0 })
            .subscribe(onSuccess: { [weak self] _ in
                self?.fetchCertification(isReset: true)
                self?.selectedRecoridIdList.accept([])
            })
            .disposed(by: disposeBag)
    }
    
    func toggleFitSiteAllSelection() {
        let fitSiteFeedList = self.fitSiteFeedList.value
        
        if selectedArticleidIdList.value.count == fitSiteFeedList.count {
            self.selectedArticleidIdList.accept([])
        } else {
            let allIdList = Set(fitSiteFeedList.map { $0.articleId })
            self.selectedArticleidIdList.accept(allIdList)
        }
    }
    
    func deleteFitSites() {
        guard !selectedArticleidIdList.value.isEmpty else { return }
        usecase.deleteFitSites(articleIdList: selectedArticleidIdList.value.map { $0 })
            .subscribe(onSuccess: { [weak self] _ in
                self?.fetchFitSite(isReset: true)
                self?.selectedArticleidIdList.accept([])
            })
            .disposed(by: disposeBag)
    }
}

extension MyFeedViewModel {
    private func resetFitSite() {
        self.currentFitSitePage = 0
        self.isLastFitSite = false
    }
    
    private func resetCertification() {
        self.currentCertificationPage = 0
        self.isLastCertification = false
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
        selectedCategory.asObservable()
        .take(1)
        .flatMap {
            self.usecase.fetchFitSiteFeed(categoryId: $0,
                                          page: self.currentFitSitePage).asObservable()
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
        selectedCategory.asObservable()
        .take(1)
        .flatMap {
            self.usecase.fetchCertificationFeed(categoryId: $0,
                                                page: self.currentCertificationPage).asObservable()
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
