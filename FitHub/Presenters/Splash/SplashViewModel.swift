//
//  SplashViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/05.
//

import Foundation
import RxSwift

final class SplashViewModel {
    private let homeService: HomeService
    private let disposeBag = DisposeBag()
    
    var checkStatusPublisher = PublishSubject<Bool>()
    
    init(homeService: HomeService) {
        self.homeService = homeService
    }
    
    func checkUserLoginStatus() {
        homeService.checkAuth()
            .subscribe(onSuccess: { [weak self] hasLogin in
                if hasLogin {
                    self?.checkStatusPublisher.onNext(true)
                } else {
                    self?.checkStatusPublisher.onNext(false)
                }
            }, onFailure: { [weak self] error in
                self?.checkStatusPublisher.onNext(false)
            })
            .disposed(by: disposeBag)
            
    }
    
}
