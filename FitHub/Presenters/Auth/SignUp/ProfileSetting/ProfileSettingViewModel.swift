//
//  ProfileSettingViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import UIKit
import RxCocoa
import RxSwift

class ProfileSettingViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    var registType: RegistType
    
    var usecase: ProfileSettingUseCaseProtocol
    
    let profileImage = BehaviorRelay(value: UIImage(named: "DefaultProfile"))
    
    struct Input {
        let nickNameText: Observable<String>
        let nextTap: Signal<Void>
        let duplicationCheckTap: Observable<Void>
    }
    
    struct Output {
        let nextButtonEnable: Observable<Bool>
        let nextTap: Signal<Void>
        let nickNameText: Observable<String>
        let nickNameStatus: Observable<UserInfoStatus>
        let duplicatedButtonIsHidden: Observable<Bool>
    }
    
    init(_ usecase: ProfileSettingUseCaseProtocol,
         registType: RegistType) {
        self.registType = registType
        self.usecase = usecase
    }
    
    func transform(input: Input) -> Output {
        let nickNameText = input.nickNameText
            .map { $0.filter { $0.isLetter } }
            .map { String($0.prefix(10)) }
        
        let duplicate = input.duplicationCheckTap.withLatestFrom(nickNameText.distinctUntilChanged())
            .flatMap { self.usecase.duplicationNickNameCheck($0).asObservable() }
        
        let nickNameStatus = Observable.of(duplicate,nickNameText.distinctUntilChanged().map { _ in .nickNameOK }).merge()
        
        let duplicatedButtonIsHidden = Observable.combineLatest(nickNameText, nickNameStatus)
            .map { !($0.count > 0 && $1 == .nickNameOK) }
        
        self.profileImage
            .subscribe(onNext: { [weak self] image in
                self?.usecase.registUserInfo.profileImage = image
            })
            .disposed(by: disposeBag)

        nickNameStatus
            .filter { $0 == .nickNameSuccess }
            .withLatestFrom(nickNameText)
            .subscribe(onNext: { [weak self] nickName in
                self?.usecase.registUserInfo.nickName = nickName
            })
            .disposed(by: disposeBag)
        
        return Output(nextButtonEnable: nickNameStatus.map { $0 == .nickNameSuccess },
                      nextTap: input.nextTap,
                      nickNameText: nickNameText,
                      nickNameStatus: nickNameStatus,
                      duplicatedButtonIsHidden: duplicatedButtonIsHidden)
    }
}
