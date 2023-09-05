//
//  HomeViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/03.
//

import UIKit
import RxSwift

final class HomeViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    let usecase: HomeUseCaseProtocol
    
    let rankingList = PublishSubject<[BestRecorderDTO]>()
    let userInfo = PublishSubject<HomeUserInfoDTO>()
    let updateDate = PublishSubject<String>()
    
    let levelInfo = PublishSubject<LevelInfoDTO>()
    let alarmCheck = PublishSubject<Bool>()
    let checkTodayHandler = PublishSubject<Bool>()
    
    struct Input {
    }
    
    struct Output {
        let category = BehaviorSubject<[CategoryDTO]>(value: [])
    }
    
    init(usecase: HomeUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        usecase.fetchCategory()
            .subscribe(onSuccess: { category in
                output.category.onNext(category)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func updateHomeInfo() {
        self.usecase.fetchHomeInfo()
            .subscribe(onSuccess: { [weak self] result in
                self?.userInfo.onNext(result.userInfo)
                self?.rankingList.onNext(result.bestRecorderList)
                self?.updateDate.onNext(result.bestStandardDate)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchLevelInfo() {
        usecase.fetchLevelInfo()
            .subscribe(onSuccess: { [weak self] item in
                self?.levelInfo.onNext(item)
            })
            .disposed(by: disposeBag)
    }
    
    func checkAlarm() {
        usecase.checkRemainAlarm()
            .subscribe(onSuccess: { [weak self] res in
                self?.alarmCheck.onNext(res.isRemain)
            })
            .disposed(by: disposeBag)
    }
    
    func checkHasTodayCertification() {
        usecase.checkHasTodayCertification()
            .subscribe(onSuccess: { [weak self] result in
                self?.checkTodayHandler.onNext(result.isWrite)
            })
            .disposed(by: disposeBag)
    }
}
