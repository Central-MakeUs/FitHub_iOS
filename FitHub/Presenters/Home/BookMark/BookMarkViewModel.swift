//
//  BookMarkViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation
import RxSwift
import RxCocoa

final class BookMarkViewModel {
    private let usecase: BookMarkUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    let category = BehaviorSubject<[CategoryDTO]>(value: [])
    let selectedCategory = BehaviorSubject<Int>(value: 0)
    let articleFeedList = BehaviorRelay<[ArticleDTO]>(value: [])
    let bookMarkDidScroll = PublishSubject<(CGFloat,CGFloat,CGFloat)>()
    
    // Paging
    var isPaging = false
    var currentPage = 0
    var isLast = false
    
    init(usecase: BookMarkUseCaseProtocol) {
        self.usecase = usecase
        
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] response in
                self?.category.onNext(response)
            })
            .disposed(by: disposeBag)
        
        selectedCategory
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] type in
                self?.resetBookMark()
                self?.fetchBookMark(isReset: true)
            })
            .disposed(by: disposeBag)
        
        bookMarkDidScroll
            .filter { $0.1 != 0.0 }
            .subscribe(onNext: { [weak self] (offsetY, contentHeight, frameHeight) in
                guard let self else { return }
                if offsetY > (contentHeight - frameHeight) {
                    if self.isPaging == false && !isLast { self.paging() }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func viewWillAppear() {
        resetBookMark()
        fetchBookMark(isReset: true)
    }
}

extension BookMarkViewModel {
    private func resetBookMark() {
        currentPage = 0
        isLast = false
    }
    
    private func fetchBookMark(isReset: Bool) {
        selectedCategory.asObservable()
            .take(1)
            .flatMap {
                self.usecase.fetchBookMark(categoryId: $0, page: self.currentPage)
                    .asObservable()
                    .catch { error in
                        return Observable.empty()
                    }
            }
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                var newValue = self.articleFeedList.value
                if isReset { newValue = [] }
                newValue.append(contentsOf: result.articleList)
                self.articleFeedList.accept(newValue)
                self.isLast = result.isLast
            },onDisposed: { [weak self] in
                self?.isPaging = false
            })
            .disposed(by: disposeBag)
    }
    
    private func paging() {
        self.isPaging = true
        currentPage += 1
        fetchBookMark(isReset: false)
    }
}
