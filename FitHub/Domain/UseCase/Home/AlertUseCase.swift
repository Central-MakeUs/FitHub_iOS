//
//  AlertUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/23.
//

import Foundation
import RxSwift

protocol AlertUseCaseProtocol {
    func confirmAlram(alarmId: Int)->Single<Bool>
    func fetchAlramList(page: Int)->Single<AlarmListDTO>
}

final class AlertUseCase: AlertUseCaseProtocol {
    private let alarmRepo: AlarmRepositoryInterface
    
    init(alarmRepo: AlarmRepositoryInterface) {
        self.alarmRepo = alarmRepo
    }
    
    func confirmAlram(alarmId: Int)->Single<Bool> {
        return alarmRepo.confirmAlram(alarmId: alarmId)
    }
    
    func fetchAlramList(page: Int)->Single<AlarmListDTO> {
        return alarmRepo.fetchAlramList(page: page)
    }
}
