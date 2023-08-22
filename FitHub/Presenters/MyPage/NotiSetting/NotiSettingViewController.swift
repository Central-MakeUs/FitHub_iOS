//
//  NotiSettingViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import UIKit
import RxSwift
import RxCocoa

final class NotiSettingViewController: BaseViewController {
    private let viewModel: NotiSettingViewModel
    
    private let myFeedNotification = SwitchView(title: "내 게시글 알림")
    private let marketingNotification = SwitchView(title: "마케팅 메세지 알림")
    
    init(viewModel: NotiSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        self.title = "알림 설정"
    }
    
    override func setupBinding() {
        let input = NotiSettingViewModel.Input(communitySwitchTap: myFeedNotification.switchButton.rx.tap.asObservable(),
                                               marketingSwitchTap: marketingNotification.switchButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.notiSettingHandler
            .bind(onNext: { [weak self] item in
                self?.myFeedNotification.configureSwitch(isOn: item.communityPermit)
                self?.marketingNotification.configureSwitch(isOn: item.marketingPermit)
            })
            .disposed(by: disposeBag)
    }
    
    override func addSubView() {
        [myFeedNotification, marketingNotification].forEach {
            self.view.addSubview($0)
        }
    }
    
    override func layout() {
        myFeedNotification.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        marketingNotification.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(myFeedNotification.snp.bottom).offset(10)
        }
    }
}
