//
//  ViewModelType.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}
