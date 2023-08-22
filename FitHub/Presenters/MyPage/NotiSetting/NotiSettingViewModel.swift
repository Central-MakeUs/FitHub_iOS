//
//  NotiSettingViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import Foundation
import RxSwift
import RxCocoa

final class NotiSettingViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    private let usecase: NotiSettingUseCaseProtocol
    
    var communityPermit: Bool = false
    var marketingPermit: Bool = false
    
    struct Input {
        let communitySwitchTap: Observable<Void>
        let marketingSwitchTap: Observable<Void>
    }
    
    struct Output {
        let notiSettingHandler = PublishSubject<NotiSettingDTO>()
    }
    
    init(usecase: NotiSettingUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        usecase.checkNotiSetting()
            .subscribe(onSuccess: { [weak self] item in
                output.notiSettingHandler.onNext(item)
                self?.communityPermit = item.communityPermit
                self?.marketingPermit = item.marketingPermit
            })
            .disposed(by: disposeBag)
        
        input.communitySwitchTap
        .flatMap {
            self.usecase.updateNotiSetting(communityPermit: !self.communityPermit,
                                           marketingPermit: self.marketingPermit).asObservable()
                .catch { _ in
                    return Observable.empty()
                }
        }
        .subscribe(onNext: { [weak self] item in
            output.notiSettingHandler.onNext(item)
            self?.communityPermit = item.communityPermit
            self?.marketingPermit = item.marketingPermit
        })
        .disposed(by: disposeBag)
        
        input.marketingSwitchTap
        .flatMap {
            self.usecase.updateNotiSetting(communityPermit: self.communityPermit,
                                           marketingPermit: !self.marketingPermit).asObservable()
                .catch { _ in
                    return Observable.empty()
                }
        }
        .subscribe(onNext: { [weak self] item in
            output.notiSettingHandler.onNext(item)
            self?.communityPermit = item.communityPermit
            self?.marketingPermit = item.marketingPermit
        })
        .disposed(by: disposeBag)
        
        return output
    }
}
