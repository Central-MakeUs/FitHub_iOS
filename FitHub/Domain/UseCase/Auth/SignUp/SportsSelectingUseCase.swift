//
//  SportsSelectingUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/25.
//

import Foundation
import RxSwift

protocol SportsSelectingUseCaseProtocol {
    var registUserInfo: AuthUserInfo { get set }
    var sports: BehaviorSubject<[CategoryDTO]> { get set }
    var selectedIds: BehaviorSubject<[Int]> { get set }
    
    func signUpWithPhoneNumber() -> Single<RegistResponseDTO>
    func signUpWithOAuth() -> Single<RegistResponseDTO>
}

final class SportsSelectingUseCase: SportsSelectingUseCaseProtocol {
    private let repository: SportsSelectingRepositoryInterface
    private let disposeBag = DisposeBag()
    
    var registUserInfo: AuthUserInfo {
        didSet {
            self.selectedIds.onNext(self.registUserInfo.preferExercise.map { $0.id })
        }
    }
    
    var selectedIds: BehaviorSubject<[Int]> = BehaviorSubject(value: [])
    
    var sports = BehaviorSubject<[CategoryDTO]>(value: [])
    
    init(_ userInfo: AuthUserInfo,
         repository: SportsSelectingRepositoryInterface) {
        self.registUserInfo = userInfo
        self.repository = repository
        
        repository.fetchCategory()
            .subscribe(onSuccess: { categories in
                self.sports.onNext(categories)
            })
            .disposed(by: disposeBag)
    }
    
    func signUpWithPhoneNumber() -> Single<RegistResponseDTO> {
        return self.repository.signUpWithPhoneNumber(self.registUserInfo)
    }
    
    //소셜회원가입 api 모호함. 추후 변경예정
//    func signUpWithOAuth() -> Single<RegistResponseDTO> {
//        return self.repositor
//    }
}
