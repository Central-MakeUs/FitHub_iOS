//
//  RegistInfoViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/29.
//

import Foundation
import RxSwift
import RxCocoa

class RegistInfoViewModel {
    let telecomProviders = Observable.of(TelecomProviderType.allCases)
    
    let selectedTelecomProvider: BehaviorRelay<TelecomProviderType?> = BehaviorRelay(value: nil)
    
//    let dateOfBirthInput = 
}
