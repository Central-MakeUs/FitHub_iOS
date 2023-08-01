//
//  CommunityViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation
import RxSwift

class CommunityViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    let usecase: CommunityUseCaseProtocol
    
    struct Input {
        
    }
    
    struct Output {
        let category: BehaviorSubject<[CategoryDTO]>
        let certificationFeedList: BehaviorSubject<[CertificationItem]>
    }
    
    init(_ usecase: CommunityUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        
        
        return Output(category: usecase.category,
                      certificationFeedList: usecase.recordList)
    }
}
