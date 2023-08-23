//
//  AlarmRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/23.
//

import Foundation
import RxSwift

protocol AlarmRepositoryInterface {
    func confirmAlram(alarmId: Int)->Single<Bool>
    func fetchAlramList(page: Int)->Single<AlarmListDTO>
}

final class AlarmRepository: AlarmRepositoryInterface {
    private let service: AlarmService
    
    init(service: AlarmService) {
        self.service = service
    }
    
    func confirmAlram(alarmId: Int)->Single<Bool> {
        return service.confirmAlram(alarmId: alarmId)
    }
    
    func fetchAlramList(page: Int)->Single<AlarmListDTO> {
        return service.fetchAlramList(page: page)
    }
}
