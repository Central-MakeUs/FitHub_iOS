//
//  PasswordSettingViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import UIKit

final class PasswordSettingViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: PasswordSettingViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "비밀번호 설정"
        $0.textColor = .textDefault
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "비밀번호를 설정해주세요."
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodyMedium01)
    }
    
    private let passwordInputTextFieldView = StandardTextFieldView("비밀번호").then {
        $0.textField.isSecureTextEntry = true
        $0.placeholder = "비밀번호 입력"
        $0.textField.keyboardType = .alphabet
    }
    
    private let passwordVerificationTextFieldView = StandardTextFieldView("비밀번호 확인").then {
        $0.textField.isSecureTextEntry = true
        $0.placeholder = "비밀번호 재입력"
        $0.textField.keyboardType = .alphabet
    }
    
    private let nextButton = StandardButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
    }
    
    init(_ viewModel: PasswordSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupBinding() {
        let input = PasswordSettingViewModel.Input(passwordInput: self.passwordInputTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                                   passwordVerificationInput: self.passwordVerificationTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                                   nextTap: self.nextButton.rx.tap.asSignal())
        let output = self.viewModel.transform(input: input)
        
        output.passwordStatus
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .passwordOK)
            .drive(onNext: { [weak self] status in
                self?.passwordInputTextFieldView.verifyFormat(status)
            })
            .disposed(by: disposeBag)
        
        output.passwordVerificationStatus
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .ok)
            .drive(onNext: { [weak self] status in
                self?.passwordVerificationTextFieldView.verifyFormat(status)
            })
            .disposed(by: disposeBag)
        
        output.nextButtonEnable
            .asDriver(onErrorJustReturn: false)
            .drive(self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.nextTap
            .emit(onNext: { [weak self] in
                self?.pushProfileSettingViewController()
            })
            .disposed(by: disposeBag)
    }
    
    private func pushProfileSettingViewController() {
        let profileSettingVM = ProfileSettingViewModel(self.viewModel.userInfo,
                                                       usecase: ProfileSettingUseCase(repository: ProfileSettingRepository(AuthService())))
        let profileSettingVC = ProfileSettingViewController(profileSettingVM)
        
        self.navigationController?.pushViewController(profileSettingVC, animated: true)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.passwordInputTextFieldView)
        self.view.addSubview(self.passwordVerificationTextFieldView)
        self.view.addSubview(self.nextButton)
    }
    
    override func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
        }
        
        self.subTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.passwordInputTextFieldView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(25)
        }
        
        self.passwordVerificationTextFieldView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.passwordInputTextFieldView.snp.bottom).offset(7)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
    }
}
