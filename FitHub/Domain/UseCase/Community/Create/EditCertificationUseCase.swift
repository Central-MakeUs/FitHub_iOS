//
//  EditCertificationUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import UIKit
import RxSwift

protocol EditCertificationUseCaseProtocol {
    var certifiactionInfo: EditCertificationModel { get set }
    
    var sports: BehaviorSubject<[CategoryDTO]> { get set }
    
    func createCertification() -> Single<CreateCertificationDTO>
}

final class EditCertificationUseCase: EditCertificationUseCaseProtocol {
    private let repository: EditCertificationRepositoryInterface
    
    var disposeBag = DisposeBag()
    
    var certifiactionInfo = EditCertificationModel()
    
    var sports = BehaviorSubject<[CategoryDTO]>(value: [])
    
    init(repository: EditCertificationRepositoryInterface) {
        self.repository = repository
        
        repository.fetchCategory()
            .subscribe(onSuccess: { categories in
                self.sports.onNext(categories)
            })
            .disposed(by: disposeBag)
    }
    
    func createCertification() -> Single<CreateCertificationDTO> {
        return self.repository.createCertification(certifiactionInfo)
    }
}
