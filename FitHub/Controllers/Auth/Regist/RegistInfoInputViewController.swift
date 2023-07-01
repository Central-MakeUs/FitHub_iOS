//
//  RegistInfoInputViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import UIKit
import RxSwift
import RxCocoa

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
        $0.textField.keyboardType = .numberPad
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
        $0.isEnabled = false
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
        let input = RegistInfoViewModel.Input(phoneTextFieldDidEditEvent: self.phoneNumberInputTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                              telecomDidSelectEvent: self.telecomProviderView.textField.rx.text.orEmpty.asObservable(),
                                              dateOfBirthTextFieldDidEditEvent: self.dateOfBirthInputTextFieldView.dateOfBirthTextField.rx.text.orEmpty.asObservable(),
                                              sexNumberTextFieldDidEditEvent: self.dateOfBirthInputTextFieldView.sexNumberTextField.rx.text.orEmpty.asObservable(),
                                              nameTextFieldDidEditEvent: self.nameInputTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                              nextButtonTapEvent: self.nextButton.rx.tap.map { [unowned self] in self.stackView.subviews.count })
        
        let output = self.viewModel.transform(input: input)
  
        output.dateOfBirth
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self, resultSelector: { ($0,$1.0,$1.1) } )
            .bind(onNext: { (obj, text, isFullNumber) in
                obj.dateOfBirthInputTextFieldView.dateOfBirthTextField.text = text
                if isFullNumber { obj.dateOfBirthInputTextFieldView.sexNumberTextField.becomeFirstResponder() }
            })
            .disposed(by: disposeBag)
        
        output.sexNumber
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self, resultSelector: { ($0,$1.0,$1.1) } )
            .bind(onNext: { (obj, text, isFullNumber) in
                obj.dateOfBirthInputTextFieldView.sexNumberTextField.text = text
                if isFullNumber { obj.dateOfBirthInputTextFieldView.sexNumberTextField.resignFirstResponder() }
            })
            .disposed(by: disposeBag)
        
        output.dateOfBirthStatus
            .asSignal(onErrorJustReturn: (.notValidSexNumber))
            .skip(1)
            .debounce(.milliseconds(1500))
            .withUnretained(self.dateOfBirthInputTextFieldView)
            .emit(onNext: { (obj,status) in
                print(status)
                obj.verifyFormat(status)
            })
            .disposed(by: disposeBag)
            
        
        output.phoneNumber
            .asSignal(onErrorJustReturn: ("",.notValidPhoneNumber))
            .skip(1)
            .debounce(.milliseconds(1500))
            .emit(onNext: { [weak self] (phNum, status) in
                self?.phoneNumberInputTextFieldView.verifyFormat(status)
            })
            .disposed(by: disposeBag)

        output.nextButtonTapEvent
            .asDriver(onErrorJustReturn: 1)
            .drive(onNext: { [weak self] stackCnt in
                guard let self else { return }
    
                switch stackCnt {
                case 1:
                    self.stackView.insertArrangedSubview(self.telecomProviderView, at: 0)
                    self.telecomProviderView.isHidden = false
                    self.present(TelecomProviderSelectorViewController(viewModel: self.viewModel), animated: false)
                case 2: self.insertSubViewWithAnimation(self.dateOfBirthInputTextFieldView)
                case 3: self.insertSubViewWithAnimation(self.nameInputTextFieldView)
                default: self.navigationController?.pushViewController(PhoneVerificationViewController(self.viewModel), animated: true)
                }
                
                self.loadViewIfNeeded()
            })
            .disposed(by: disposeBag)
        
        output.nextButtonEnable
            .asDriver(onErrorJustReturn: false)
            .drive(self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.viewModel.selectedTelecomProvider
            .compactMap { $0?.rawValue }
            .bind(to: self.telecomProviderView.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func insertSubViewWithAnimation<T: UIView>(_ subView: T) {
        UIView.animate(withDuration: 1.0, animations: {
            self.stackView.insertArrangedSubview(subView, at: 0)
            subView.isHidden = false
        })
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
