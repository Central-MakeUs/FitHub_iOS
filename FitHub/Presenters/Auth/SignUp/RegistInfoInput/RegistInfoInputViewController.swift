//
//  RegistInfoInputViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import RxKeyboard

final class RegistInfoInputViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: RegistInfoViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "휴대폰번호로 가입"
        $0.font = .pretendard(.headLineSmall)
        $0.textColor = .textDefault
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "휴대폰번호는 아이디로 사용됩니다."
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    private let phoneNumberInputTextFieldView = StandardTextFieldView("휴대폰번호").then {
        $0.placeholder = "01012345678"
        $0.textField.keyboardType = .numberPad
    }
    
    private let telecomProviderView = StandardTextFieldView("통신사").then {
        $0.placeholder = "통신사 선택"
        $0.statusImageView.image = UIImage(named: "ic_arrow_drop_down")
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
    
    private let sendButton = StandardButton(type: .system).then {
        $0.setTitle("인증번호 전송", for: .normal)
        $0.layer.cornerRadius = 0
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.responseToKeyboardHegiht(self.sendButton)
    }
    
    override func setupBinding() {
        let input = RegistInfoViewModel.Input(phoneTextFieldDidEditEvent: self.phoneNumberInputTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                              dateOfBirthTextFieldDidEditEvent: self.dateOfBirthInputTextFieldView.dateOfBirthTextField.rx.text.orEmpty.asObservable(),
                                              sexNumberTextFieldDidEditEvent: self.dateOfBirthInputTextFieldView.sexNumberTextField.rx.text.orEmpty.asObservable(),
                                              nameTextFieldDidEditEvent: self.nameInputTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                              sendButtonTapEvent: self.sendButton.rx.tap.asObservable())
        
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
            .asSignal(onErrorJustReturn: (.notValidSexNumber,false))
            .withUnretained(self, resultSelector: { ($0,$1.0,$1.1) })
            .emit(onNext: { (obj,status,isFull) in
                if isFull {
                    obj.dateOfBirthInputTextFieldView.verifyFormat(status)
                    if obj.stackView.subviews.count == 3 && status == .ok {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.stackView.insertArrangedSubview(self.nameInputTextFieldView, at: 0)
                            self.nameInputTextFieldView.isHidden = false
                            self.loadViewIfNeeded()
                        }) { _ in
                            self.nameInputTextFieldView.textField.becomeFirstResponder()
                        }
                    }
                } else {
                    obj.dateOfBirthInputTextFieldView.verifyFormat(.ok)
                }
            })
            .disposed(by: disposeBag)
        
        output.phoneNumber
            .asSignal(onErrorJustReturn: ("",.notValidPhoneNumber))
            .skip(1)
            .emit(onNext: { [weak self] (phNum, status) in
                guard let self else { return }
                self.phoneNumberInputTextFieldView.text = phNum
                
                if phNum.count == 11 {
                    if stackView.subviews.count == 1 && status == .ok {
                        self.stackView.insertArrangedSubview(self.telecomProviderView, at: 0)
                        self.telecomProviderView.isHidden = false
                        self.present(TelecomProviderSelectorViewController(viewModel: self.viewModel), animated: false)
                    }
                    self.phoneNumberInputTextFieldView.verifyFormat(status)
                } else {
                    self.phoneNumberInputTextFieldView.verifyFormat(.ok)
                }
            })
            .disposed(by: disposeBag)

        output.sendButtonTapEvent
            .bind(onNext: { [weak self] res in
                switch res {
                case .success(let code):
                    if code == 2000 {
                        self?.pushPhoneVerifactionViewController()
                    } else if code == 4018 {
                        self?.presentGuideAlert()
                    }
                case .failure(let error):
                    print(error)
                    //TODO: 에러처리
                }
            })
            .disposed(by: disposeBag)
        
        output.sendButtonEnable
            .asDriver(onErrorJustReturn: false)
            .drive(self.sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.telecom
            .asDriver(onErrorJustReturn: .SKT)
            .drive(onNext: { [weak self] telecomType in
                guard let self else { return }
                self.telecomProviderView.text = telecomType.rawValue
                self.telecomProviderView.borderColorWillChange(UIColor.iconDisabled.cgColor)
                if self.stackView.subviews.count == 2 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.stackView.insertArrangedSubview(self.dateOfBirthInputTextFieldView, at: 0)
                        self.dateOfBirthInputTextFieldView.isHidden = false
                        self.loadViewIfNeeded()
                    }) { _ in
                        self.dateOfBirthInputTextFieldView.dateOfBirthTextField.becomeFirstResponder()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        self.telecomProviderView.rx.tapGesture()
            .when(.recognized)
            .bind(onNext: { [weak self] _ in
            self?.willPresentTelecomProviderSelectorViewController()
        })
        .disposed(by: disposeBag)
    }
    
    private func presentGuideAlert() {
        let alert = StandardAlertController(title: "안내",
                                            message: "이미 가입된 휴대폰번호입니다.\n로그인을 진행할까요?")
        let cancel = StandardAlertAction(title: "닫기", style: .cancel)
        let goLogin = StandardAlertAction(title: "로그인 하러가기", style: .basic) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(goLogin)
        
        self.present(alert, animated: false)
    }
    
    //MARK: - 화면 이동
    private func pushPhoneVerifactionViewController() {
        let usecase = PhoneVerificationUseCase(repository: PhoneVerificationRepository(UserService()))
        usecase.registUserInfo = self.viewModel.usecase.registUserInfo
        let phoneVerificationVC = PhoneVerificationViewController(PhoneVerificationViewModel(usecase))
        
        self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
    }
    
    private func willPresentTelecomProviderSelectorViewController() {
        self.present(TelecomProviderSelectorViewController(viewModel: self.viewModel), animated: false)
    }
    
    private func insertSubViewWithAnimation<T: UIView>(_ subView: T) {
        UIView.animate(withDuration: 0.3, animations: {
            self.stackView.insertArrangedSubview(subView, at: 0)
            subView.isHidden = false
        })
    }
    
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.stackView)
        self.view.addSubview(self.sendButton)
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
        
        self.sendButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(56)
        }
    }
}
