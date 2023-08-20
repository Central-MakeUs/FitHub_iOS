//
//  OtherProfileViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import Foundation
import RxSwift
import RxCocoa

final class OtherProfileViewModel {
    private let disposeBag = DisposeBag()
    private let usecase: OtherProfileUseCaseProtocol
    
    private let userId: Int
    
    var isPaging = false
    var currentFitSitePage = 0
    var isLastFitSite = false
    
    init(userId: Int,
         usecase: OtherProfileUseCaseProtocol) {
        self.usecase = usecase
        self.userId = userId
        
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] response in
                self?.category.onNext(response)
            })
            .disposed(by: disposeBag)
        
        usecase.fetchOtherProfileInfo(userId: userId)
            .subscribe(onSuccess: { [weak self] response in
                self?.otherUserInfo.onNext(response)
            })
            .disposed(by: disposeBag)
        
        didScroll
            .filter { $0.1 != 0.0 }
            .subscribe(onNext: { [weak self] (offsetY, contentHeight, frameHeight) in
                guard let self else { return }
                if offsetY > (contentHeight - frameHeight) {
                    if self.isPaging == false && !isLastFitSite { self.fitSitePaging() }
                }
            })
            .disposed(by: disposeBag)
        
        selectedCategory
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.fetchFitSite(isReset: true)
            })
            .disposed(by: disposeBag)

    }
    
    // MARK: - Output
    let category = BehaviorSubject<[CategoryDTO]>(value: [])
    let selectedCategory = BehaviorSubject<Int>(value: 0)
    
    let fitSiteFeedList = BehaviorRelay<[ArticleDTO]>(value: [])
    let otherUserInfo = PublishSubject<OtherUserInfoDTO>()
    
    let didScroll = PublishSubject<(CGFloat,CGFloat,CGFloat)>()
    
    let reportUserHandler = PublishSubject<Int>()
    
}

extension OtherProfileViewModel {
    private func fitSitePaging() {
        self.isPaging = true
        currentFitSitePage += 1
        fetchFitSite(isReset: false)
    }
    
    private func fetchFitSite(isReset: Bool) {
        if isReset {
            self.currentFitSitePage = 0
            self.isLastFitSite = false
        }
        
        selectedCategory.asObservable()
            .take(1)
            .flatMap {
                self.usecase.fetchOtherUserArticle(userId: self.userId,
                                              categoryId: $0,
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
    
    func reportUser() {
        usecase.reportUser(userId: userId)
            .subscribe(onSuccess: { [weak self] code in
                self?.reportUserHandler.onNext(code)
            })
            .disposed(by: disposeBag)
        
    }
}
