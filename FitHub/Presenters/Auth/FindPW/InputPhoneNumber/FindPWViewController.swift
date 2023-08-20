//
//  FindPWViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import UIKit
import RxCocoa
import RxSwift

final class FindPWViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: FindPWViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "비밀번호 찾기"
        $0.textColor = .textDefault
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "가입할 때 입력했던 정보를 확인합니다."
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodyMedium01)
    }
    
    private let phoneNumberTextField = StandardTextFieldView("휴대폰번호").then {
        $0.keyboardType = .numberPad
        $0.placeholder = "01012345678"
    }
    
    private let sendButton = StandardButton().then {
        $0.setTitle("인증번호 전송", for: .normal)
        $0.layer.cornerRadius = 0
        $0.isEnabled = true
    }
    
    init(_ viewModel: FindPWViewModel) {
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
    
    //MARK: - Binding
    override func setupBinding() {
        let input = FindPWViewModel.Input(phoneNumber: self.phoneNumberTextField.textField.rx.text.orEmpty.asObservable(),
                                          sendButtonTap: self.sendButton.rx.tap.asObservable())
        
        let output = self.viewModel.transform(input: input)
        
        output.phoneNumber
            .asDriver(onErrorJustReturn: "")
            .drive(self.phoneNumberTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.phoneStatus
            .asDriver(onErrorJustReturn: ("", .ok) )
            .drive(onNext: { [weak self] (text,status) in
                guard let self else { return }
                
                if text.count == 11 {
                    self.phoneNumberTextField.verifyFormat(status)
                } else {
                    self.phoneNumberTextField.verifyFormat(.ok)
                }
            })
            .disposed(by: disposeBag)
        
        output.sendButtonEnabled
            .asDriver(onErrorJustReturn: false)
            .drive(self.sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.checkUserInfo
            .bind(onNext: { [weak self] res in
                switch res {
                case .success(let code):
                    if code == 2000 {
                        self?.pushPhoneVerificationViewController()
                    } else if code == 4019 {
                        self?.checkUserInfoAlert()
                    }
                case .failure(let error):
                    print(error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func pushPhoneVerificationViewController() {
        let usecase = PhoneVerificationUseCase(repository: PhoneVerificationRepository(UserService()))
        usecase.registUserInfo = self.viewModel.usecase.userInfo
        
        let phoneVerificationVC = PhoneVerificationViewController(PhoneVerificationViewModel(usecase))
        
        self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
    }
    
    private func checkUserInfoAlert() {
        let alert = StandardAlertController(title: "미가입 계정", message: "해당 번호로 가입된 계정이 없습니다.")
        
        let cancel = StandardAlertAction(title: "닫기", style: .cancel)
        let regist = StandardAlertAction(title: "회원가입 하기", style: .basic) { _ in
            let agreementVC = AgreementViewController(AgreementViewModel(AgreementUseCase(),
                                                                         registType: .Phone))
            if let idx = self.navigationController?.viewControllers.lastIndex(of: self) {
                self.navigationController?.viewControllers[idx - 1] = agreementVC
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(regist)
        
        self.present(alert, animated: false)
    }
    
    //MARK: - addSubView
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.phoneNumberTextField)
        self.view.addSubview(self.sendButton)
    }
    
    //MARK: - Layout
    override func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
        }
        
        self.subTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.phoneNumberTextField.snp.makeConstraints {
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.sendButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}
