//
//  AlertViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/23.
//

import Foundation
import RxSwift
import RxCocoa

final class AlertViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    private let usecase: AlertUseCaseProtocol
    
    var currentPage = 0
    var isPaging = false
    var isLast = false
    
    let alarmDataList = BehaviorRelay<[AlarmDTO]>(value: [])
    
    struct Input {
        let didScroll: Observable<(offsetY: CGFloat, contentHeight: CGFloat, frameHeight: CGFloat)>
    }
    
    struct Output {

    }
    
    init(usecase: AlertUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.didScroll
            .filter { $0.1 != 0.0 }
            .subscribe(onNext: { [weak self] (offsetY, contentHeight, frameHeight) in
                guard let self else { return }
                if offsetY > (contentHeight - frameHeight) {
                    if self.isPaging == false && !isLast { self.paging() }
                }
            })
            .disposed(by: disposeBag)
        return output
    }
    
    func fetchAlarmList() {
        usecase.fetchAlramList(page: currentPage)
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }
                var newValue = self.alarmDataList.value
                newValue.append(contentsOf: result.alarmList)
                self.alarmDataList.accept(newValue)
                self.isLast = result.isLast
            },onDisposed: { [weak self] in
                self?.isPaging = false
            })
            .disposed(by: disposeBag)
    }
    
    func confirmAlarmm(alarmId: Int) {
        usecase.confirmAlram(alarmId: alarmId)
            .subscribe(onSuccess: { [weak self] isSuccess in
                guard let self else { return }
                if isSuccess {
                    guard let idx = alarmDataList.value.firstIndex(where: { $0.alarmId == alarmId }) else { return }
                    var newList = alarmDataList.value
                    newList[idx].isConfirmed = !newList[idx].isConfirmed
                    self.alarmDataList.accept(newList)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension AlertViewModel {
    private func paging() {
        self.isPaging = true
        currentPage += 1
        fetchAlarmList()
    }
}
