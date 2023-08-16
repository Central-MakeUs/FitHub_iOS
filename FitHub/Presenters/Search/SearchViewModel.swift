//
//  SearchViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import UIKit
import RxSwift
import RxCocoa

enum SearchTabItemType: Int {
    case total = 0
    case certification = 1
    case fitSite = 2
}

final class SearchViewModel {
    private let usecase: SearchUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    var isFirstViewDidAppear = true
    
    // Paging
    var isPaging = false
    var currentCertificationPage = 0
    var isLastCertification = false
    
    var currentFitSitePage = 0
    var isLastFitSite = false
    
    // MARK: - Input
    let keywordTap = PublishSubject<String>()
    let communityType = PublishSubject<SearchTabItemType>()
    let searchText = BehaviorRelay<String>(value: "")
    
    let certificationSortingType = BehaviorSubject<SortingType>(value: .recent)
    let fitStieSortingType = BehaviorSubject<SortingType>(value: .recent)
    let certificationDidScroll = PublishSubject<(CGFloat,CGFloat,CGFloat)>()
    let fitSiteDidScroll = PublishSubject<(CGFloat,CGFloat,CGFloat)>()
    
    // MARK: - Output
    let topTabBarItems = Observable.of(["전체","운동인증","핏사이트"])
    let keywords = BehaviorSubject<[String]>(value: [])
    let totalDataSource = PublishSubject<[SearchTotalSectionModel]>()
    let certificationFeedList = BehaviorRelay<[CertificationDTO]>(value: [])
    let fitSiteFeedList = BehaviorRelay<[ArticleDTO]>(value: [])
    
    init(usecase: SearchUseCaseProtocol) {
        self.usecase = usecase
        
        usecase.fetchRecommendKeyword()
            .subscribe(onSuccess: { [weak self] item in
                self?.keywords.onNext(item.keywordList)
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
        
        searchText
            .subscribe(onNext: { [weak self] _ in
                self?.fetchFitSite(isReset: true)
                self?.fetchCertification(isReset: true)
                self?.communityType.onNext(.total)
                self?.fetchTotalResult()
                // TODO: 전체 결과 띄욱
            })
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
}

extension SearchViewModel {

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
        Observable.combineLatest(searchText.asObservable(),
                                 fitStieSortingType.asObservable())
        .take(1)
        .flatMap {
            self.usecase.searchToFitSite(tag: $0.0,
                                         page: self.currentFitSitePage,
                                         type: $0.1).asObservable()
                .catch { error in
                    return Observable.empty()
                }
        }
        .subscribe(onNext: { [weak self] result in
            guard let result else {
                self?.fitSiteFeedList.accept([])
                return
            }
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
        Observable.combineLatest(searchText.asObservable(),
                                 certificationSortingType.asObservable())
        .take(1)
        .flatMap {
            self.usecase.searchCertification(tag: $0.0,
                                             page: self.currentCertificationPage,
                                             type: $0.1).asObservable()
                .catch { error in
                    return Observable.empty()
                }
        }
        .subscribe(onNext: { [weak self] result in
            guard let result else {
                self?.certificationFeedList.accept([])
                return
            }
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
    
    private func fetchTotalResult() {
        self.usecase.searchTotalItem(tag: searchText.value).asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let result else {
                    let resultDatasource = [SearchTotalSectionModel.certification(items: [])] + [ SearchTotalSectionModel.fitSite(items: [])]
                    self?.totalDataSource.onNext(resultDatasource)
                    return
                }
                let recordDataSource = result.recordPreview.recordList.prefix(3)
                    .map { SearchTotalSectionModel.Item.certification(record: $0) }
                    
                let articleDataSource = result.articlePreview.articleList.prefix(3)
                    .map { SearchTotalSectionModel.Item.fitSite(article: $0) }

                let resultDatasource = [SearchTotalSectionModel.certification(items: recordDataSource)] + [ SearchTotalSectionModel.fitSite(items: articleDataSource)]
                
                self?.totalDataSource.onNext(resultDatasource)
            })
            .disposed(by: disposeBag)
    }
}
