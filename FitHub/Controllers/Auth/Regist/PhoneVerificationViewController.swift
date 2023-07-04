//
//  PhoneVerificationViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import UIKit

final class PhoneVerificationViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: RegistInfoViewModel
    
    private let verificationNumberTextField = StandardTextFieldView("인증번호").then {
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
    
    private let nextButton = StandardButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
    }
    
    //MARK: - Init
    init(_ viewModel: RegistInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        self.nextButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController?.pushViewController(PasswordSettingViewController(self.viewModel), animated: true)
            })
            .disposed(by: disposeBag)
        
        self.verificationNumberTextField.textField.rx.text.orEmpty
            .map { String($0.prefix(6)) }
            .bind(to: self.viewModel.authenticationNumber)
            .disposed(by: disposeBag)
        
        self.viewModel.authenticationNumber
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] text in
                guard let self else { return }
                self.verificationNumberTextField.textField.text = text
            })
            .disposed(by: disposeBag)
        
        self.viewModel.authenticationNumber
            .map { $0.count == 6 }
            .bind(to: self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.resendButton.rx.tap
            .asDriver()
            .drive (onNext:{
                self.notiAlert("인증번호 재발송")
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.verificationNumberTextField)
        self.view.addSubview(self.codeNotReceivedLabel)
        self.view.addSubview(self.resendButton)
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
        
        self.codeNotReceivedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.verificationNumberTextField.snp.bottom).offset(15)
        }
        
        self.resendButton.snp.makeConstraints {
            $0.leading.equalTo(self.codeNotReceivedLabel.snp.trailing).offset(6)
            $0.centerY.equalTo(self.codeNotReceivedLabel)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
    }
}
