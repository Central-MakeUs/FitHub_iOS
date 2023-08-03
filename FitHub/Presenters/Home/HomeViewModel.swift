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
   
    
    struct Input {
        
    }
    
    struct Output {
        let category: Observable<[CategoryDTO]>
        let userInfo: Observable<HomeUserInfoDTO>
        let rankerList: Observable<[BestRecorderDTO]>
        let updateDate: Observable<String>
    }
    
    init(usecase: HomeUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        
        
        return Output(category: self.usecase.category.asObserver(),
                      userInfo: self.usecase.userInfo.asObserver(),
                      rankerList: self.usecase.rankingList.asObserver(),
                      updateDate: self.usecase.updateDate.asObserver())
    }
    
    func updateHomeInfo() {
        self.usecase.fetchHomeInfo()
        self.usecase.fetchCategory()
    }
}
