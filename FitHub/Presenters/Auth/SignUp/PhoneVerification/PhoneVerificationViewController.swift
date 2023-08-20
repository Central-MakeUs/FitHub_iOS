//
//  PhoneVerificationViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import UIKit
import RxCocoa
import RxSwift

final class PhoneVerificationViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: PhoneVerificationViewModel
    
    private let verificationNumberTextField = VerificationNumberTextFieldView("인증번호").then {
        $0.placeholder = "인증번호 6자리 입력"
        $0.textField.keyboardType = .numberPad
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "인증번호 확인"
        $0.textColor = .textDefault
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "휴대폰으로 발송한 인증번호를 입력해주세요"
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodyMedium01)
    }
    
    private let codeNotReceivedLabel = UILabel().then {
        $0.text = "인증번호가 오지 않는다면?"
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodySmall01)
    }
    
    private let resendButton = UIButton(type: .system).then {
        var attribute = AttributedString.init("재발송")
        attribute.font = .pretendard(.bodyMedium01)
        attribute.foregroundColor = .textSub01
        attribute.underlineStyle = .single
        attribute.underlineColor = .textDisabled
        $0.setAttributedTitle(NSAttributedString(attribute), for: .normal)
    }
    
    private lazy var labelStackView = UIStackView(arrangedSubviews: [codeNotReceivedLabel,resendButton]).then {
        $0.spacing = 6
    }
    
    private let nextButton = StandardButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
        $0.layer.cornerRadius = 0
        $0.isEnabled = false
    }
    
    //MARK: - Init
    init(_ viewModel: PhoneVerificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.responseToKeyboardHegiht(self.nextButton)
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        let input = PhoneVerificationViewModel.Input(authenticationNumber: self.verificationNumberTextField.textField.rx.text.orEmpty.asObservable(),
                                                     resendTap: self.resendButton.rx.tap.asSignal(),
                                                     nextTap: self.nextButton.rx.tap.asSignal())
        
        let output = self.viewModel.transform(input: input)
        
        output.nextButtonEnable
            .asDriver(onErrorJustReturn: false)
            .drive(self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.authNumber
            .observe(on: MainScheduler.asyncInstance)
            .catchAndReturn("")
            .bind(to: self.verificationNumberTextField.textField.rx.text)
            .disposed(by: disposeBag)
        
        output.time
            .map { remainingTime in
                let minutes = remainingTime / 60
                let seconds = remainingTime % 60
                return String(format: "%2d:%02d", minutes, seconds)
            }
            .bind(to: self.verificationNumberTextField.timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.resendTap
            .emit(onNext: { [weak self] in self?.notiAlert("인증번호 재전송")})
            .disposed(by: disposeBag)
        
        output.authNumberPublisher
            .bind(onNext: { [weak self] res in
                switch res {
                case .success(let code):
                    if code == 2000 {
                        self?.pushPasswordSettingViewController()
                    } else if code == 4014 {
                        self?.notiAlert("인증번호 불일치")
                    } else if code == 4015 {
                        self?.notiAlert("유효시간 초과")
                    } else {
                        self?.notiAlert("알 수 없는 오류\n다시 시도해주세요.")
                    }
                case .failure(let error):
                    print(error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    //MARK: - 화면이동
    private func pushPasswordSettingViewController() {
        guard let userInfo = self.viewModel.usecase.registUserInfo else { return }
        
        if let _ = userInfo.name {
            let usecase = PasswordUseCase(userInfo)
            let passwordSettingVC = PasswordSettingViewController(PasswordSettingViewModel(usecase: usecase))
            
            self.navigationController?.pushViewController(passwordSettingVC, animated: true)
        } else {
            //TODO: 비밀번호 재설정 페이지 이동
            let usecase = ResetPasswordUseCase(ResetPasswordRepository(service: UserService()),
                                               userInfo: userInfo)
            let passwordResetVC = ResetPasswordViewController(ResetPasswordViewModel(usecase))
            self.navigationController?.pushViewController(passwordResetVC, animated: true)
        }
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.verificationNumberTextField)
        self.view.addSubview(self.labelStackView)
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
        
        self.verificationNumberTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(25)
        }
        
        self.labelStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.verificationNumberTextField.snp.bottom).offset(15)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
    }
}
