//
//  EditCertifiactionViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/28.
//

import Foundation
import RxSwift

final class EditCertifiactionViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    var usecase: EditCertificationUseCaseProtocol
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init(usecase: EditCertificationUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
