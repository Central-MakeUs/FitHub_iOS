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
    }
    
    func viewWillAppear() {
        resetBookMark()
        fetchBookMark()
    }
}

extension BookMarkViewModel {
    private func resetBookMark() {
        currentPage = 0
        isLast = false
        articleFeedList.accept([])
    }
    
    private func fetchBookMark() {
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
                newValue.append(contentsOf: result.articleList)
                self.articleFeedList.accept(newValue)
                self.isLast = result.isLast
            },onDisposed: { [weak self] in
                self?.isPaging = false
            })
            .disposed(by: disposeBag)
    }
}
