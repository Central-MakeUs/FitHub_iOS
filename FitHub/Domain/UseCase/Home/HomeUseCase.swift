//
//  HomeUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/03.
//

import Foundation
import RxSwift

protocol HomeUseCaseProtocol {
    var rankingList: PublishSubject<[BestRecorderDTO]> { get set }
    var userInfo: PublishSubject<HomeUserInfoDTO> { get set }
    var category: PublishSubject<[CategoryDTO]> { get set }
    var updateDate: PublishSubject<String> { get set }
    
    func fetchCategory()
    func fetchHomeInfo()
    
    func checkAuth() -> Single<Bool>
}

final class HomeUseCase: HomeUseCaseProtocol {
    private let repository: HomeRepositoryInterface
    var disposeBag = DisposeBag()
    
    var rankingList = PublishSubject<[BestRecorderDTO]>()
    var userInfo = PublishSubject<HomeUserInfoDTO>()
    var category = PublishSubject<[CategoryDTO]>()
    var updateDate = PublishSubject<String>()
    
    init(repository: HomeRepositoryInterface) {
        self.repository = repository
    }
    
    func fetchHomeInfo() {
        self.repository.fetchHomeInfo()
            .subscribe(onSuccess: { [weak self] result in
                self?.userInfo.onNext(result.userInfo)
                self?.rankingList.onNext(result.bestRecorderList)
                self?.updateDate.onNext(result.bestStandardDate)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchCategory() {
        self.repository.fetchCategory()
            .subscribe(onSuccess: { [weak self] category in
                self?.category.onNext(category)
            })
            .disposed(by: disposeBag)
    }
    
    func checkAuth() -> Single<Bool> {
        return self.repository.checkAuth()
    }
}
