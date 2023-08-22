//
//  TermOfUseViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import Foundation
import RxSwift
import RxCocoa

final class TermOfUseViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    private let usecase: TermUseCaseProtocol
    
    struct Input {
        
    }
    
    struct Output {
        let termList = PublishSubject<[TermsDTO]>()
    }
    
    init(usecase: TermUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        usecase.fetchTermList()
            .subscribe(onSuccess: { termList in
                output.termList.onNext(termList.termsDtoList)
            })
            .disposed(by: disposeBag)
            
        return output
    }
}
