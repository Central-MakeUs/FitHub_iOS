//
//  RegistInfoInputViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import UIKit

final class RegistInfoInputViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: RegistInfoViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "휴대폰 번호로 가입"
        $0.font = .pretendard(.headLineSmall)
        $0.textColor = .textDefault
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "휴대폰번호는 아이디로 사용됩니다."
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    private let phoneNumberInputTextFieldView = StandardTextFieldView("휴대폰 번호").then {
        $0.placeholder = "01012345678"
    }
    
    private let telecomProviderView = StandardTextFieldView("통신사").then {
        $0.placeholder = "통신사 선택"
        $0.isHidden = true
        $0.isTextFieldEnabled = false
    }
    
    private let dateOfBirthInputTextFieldView = DateOfBirthTextFieldView().then {
        $0.isHidden = true
    }
    
    private let nameInputTextFieldView = StandardTextFieldView("이름").then {
        $0.placeholder = "이름입력"
        $0.isHidden = true
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [phoneNumberInputTextFieldView]).then {
        $0.spacing = 10
        $0.axis = .vertical
    }
    
    private let nextButton = StandardButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
    }
    
    //Init
    init(_ viewModel: RegistInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupBinding() {
        self.nextButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                if self.stackView.subviews.count == 1 {
                    self.stackView.insertArrangedSubview(self.telecomProviderView, at: 0)
                    self.telecomProviderView.isHidden = false
                    self.present(TelecomProviderSelectorViewController(viewModel: self.viewModel), animated: false)
                } else if self.stackView.subviews.count == 2 {
                    UIView.animate(withDuration: 1, animations: {
                        self.stackView.insertArrangedSubview(self.dateOfBirthInputTextFieldView, at: 0)
                        self.dateOfBirthInputTextFieldView.isHidden = false
                    })
                } else if self.stackView.subviews.count == 3 {
                    UIView.animate(withDuration: 1, animations: {
                        self.stackView.insertArrangedSubview(self.nameInputTextFieldView, at: 0)
                        self.nameInputTextFieldView.isHidden = false
                    })
                } else {
                    self.navigationController?.pushViewController(PhoneVerificationViewController(self.viewModel), animated: true)
                    return
                }
                self.loadViewIfNeeded()
            })
            .disposed(by: disposeBag)
        
        self.viewModel.selectedTelecomProvider
            .compactMap { $0?.rawValue }
            .bind(to: self.telecomProviderView.rx.text)
            .disposed(by: disposeBag)
    }
    
    
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.nextButton)
        self.view.addSubview(self.stackView)
    }
    
    override func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.subTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.stackView.snp.makeConstraints {
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            
        }
        
        self.nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(56)
        }
    }
}
