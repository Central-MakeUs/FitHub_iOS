//
//  CreateCertificationUseCaseProtocol.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import UIKit
import RxSwift

protocol CreateCertificationUseCaseProtocol {
    var certifiactionInfo: CreateCertificationModel { get set }
    
    var sports: BehaviorSubject<[CategoryDTO]> { get set }
    
    func createCertification() -> Single<CreateCertificationDTO>
    func updateCertification(recordId: Int, certificationInfo: CreateCertificationModel) -> Single<UpdateCertificationDTO>
}

final class CreateCertificationUseCase: CreateCertificationUseCaseProtocol {
    private let repository: CreateCertificationRepositoryInterface
    
    var disposeBag = DisposeBag()
    
    var certifiactionInfo = CreateCertificationModel()
    
    var sports = BehaviorSubject<[CategoryDTO]>(value: [])
    
    init(repository: CreateCertificationRepositoryInterface) {
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
    
    func updateCertification(recordId: Int, certificationInfo: CreateCertificationModel) -> Single<UpdateCertificationDTO> {
        return self.repository.updateCertification(recordId: recordId, certificationInfo: self.certifiactionInfo)
    }
}
