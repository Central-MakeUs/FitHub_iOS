//
//  OAuthRegistInputViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import UIKit
import RxSwift

final class OAuthRegistInputViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: OAuthRegistInputViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "기본정보 입력"
        $0.font = .pretendard(.headLineSmall)
        $0.textColor = .textDefault
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "이름과 생년월일을 입력해주세요."
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    private let dateOfBirthInputTextFieldView = DateOfBirthTextFieldView()
    
    private let nameInputTextFieldView = StandardTextFieldView("이름").then {
        $0.placeholder = "이름입력"
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [nameInputTextFieldView,
                                                                dateOfBirthInputTextFieldView]).then {
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.axis = .vertical
    }
    
    private let nextButton = StandardButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
        $0.layer.cornerRadius = 0
        $0.isEnabled = false
    }
    
    init(_ viewModel: OAuthRegistInputViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        let input = OAuthRegistInputViewModel.Input(name: self.nameInputTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                                    dateNumber: self.dateOfBirthInputTextFieldView.dateOfBirthTextField.rx.text.orEmpty.asObservable(),
                                                    gender: self.dateOfBirthInputTextFieldView.sexNumberTextField.rx.text.orEmpty.asObservable(),
                                                    nextTap: self.nextButton.rx.tap.asObservable())
        
        let output = self.viewModel.transform(input: input)
        
        output.nextButtonEnable
            .bind(to: self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.nextTap
            .bind(onNext:  { [weak self] in
                self?.pushProfileSettingViewController()
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - 화면이동
    private func pushProfileSettingViewController() {
        let usecase = ProfileSettingUseCase(repository: ProfileSettingRepository(UserService()),
                                            userInfo: self.viewModel.usecase.registUserInfo)
        let profileSettingVC = ProfileSettingViewController(ProfileSettingViewModel(usecase,
                                                                                    registType: self.viewModel.registType))
        
        self.navigationController?.pushViewController(profileSettingVC, animated: true)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.stackView)
        self.view.addSubview(self.nextButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.responseToKeyboardHegiht(self.nextButton)
    }
    
    //MARK: - layout
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
