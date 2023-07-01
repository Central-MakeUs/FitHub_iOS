//
//  PhoneAuthViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//

import UIKit

final class PhoneAuthViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: PhoneAuthViewModel
    
    private let mainLabel = UILabel().then {
        $0.textColor = .textDefault
        $0.text = "로그인하고\n핏허브를 즐겨보세요!"
        $0.numberOfLines = 0
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let phoneNumberTextFieldView = StandardTextFieldView("휴대폰번호").then {
        $0.placeholder = "01012345678"
        $0.keyboardType = .numberPad
    }
    
    private let passwordTextFieldView = StandardTextFieldView("비밀번호").then {
        $0.placeholder = "비밀번호 입력"
        $0.keyboardType = .numberPad
    }
    
    private let loginButton = StandardButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.isEnabled = false
    }
    
    private let findPasswordButton = UIButton(type: .system).then {
        $0.setTitle("비밀번호 찾기  |", for: .normal)
        $0.setTitleColor(.textSub02, for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
    }
    
    private let registButton = UIButton(type: .system).then {
        $0.setTitle("  회원가입", for: .normal)
        $0.setTitleColor(.textSub02, for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [findPasswordButton,registButton])
    
    //MARK: - Init
    init(_ viewModel: PhoneAuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: -SetupBinding
    override func setupBinding() {
        self.registButton.rx.tap
            .asDriver()
            .drive(onNext: {
                let agreementVC = AgreementViewController(AgreementViewModel())
                self.navigationController?.pushViewController(agreementVC, animated: true)
            })
            .disposed(by: disposeBag)
    }

    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.mainLabel)
        self.view.addSubview(self.phoneNumberTextFieldView)
        self.view.addSubview(self.passwordTextFieldView)
        self.view.addSubview(self.loginButton)
        self.view.addSubview(self.stackView)
    }
    
    //MARK: - Layout
    override func layout() {
        self.mainLabel.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(15)
        }
        
        self.phoneNumberTextFieldView.snp.makeConstraints {
            $0.top.equalTo(self.mainLabel.snp.bottom).offset(29)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.passwordTextFieldView.snp.makeConstraints {
            $0.top.equalTo(self.phoneNumberTextFieldView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.loginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(52)
        }
        
        self.stackView.snp.makeConstraints {
            $0.bottom.equalTo(self.loginButton.snp.top).offset(-15)
            $0.centerX.equalToSuperview()
        }
    }
}
