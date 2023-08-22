//
//  TermUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import Foundation
import RxSwift

protocol TermUseCaseProtocol {
    func fetchTermList()->Single<TermsListDTO>
}

final class TermUseCase: TermUseCaseProtocol {
    private let homeRepo: HomeRepositoryInterface
    
    init(homeRepo: HomeRepositoryInterface) {
        self.homeRepo = homeRepo
    }
    
    func fetchTermList()->Single<TermsListDTO> {
        return homeRepo.fetchTermList()
    }
}
