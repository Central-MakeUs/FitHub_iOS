//
//  PasswordConfirmViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/19.
//

import UIKit
import RxSwift
import RxCocoa

final class PasswordConfirmViewController: BaseViewController {
    private let viewModel: ResetPWViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "비밀번호 확인"
        $0.font = .pretendard(.headLineSmall)
        $0.textColor = .textDefault
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "재설정을 위해 기존 비밀번호를 입력해주세요."
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    private let passwordInputTextFieldView = StandardTextFieldView("비밀번호").then {
        $0.placeholder = "비밀번호 입력"
        $0.textField.isSecureTextEntry = true
    }
    
    private let confirmButton = StandardButton(type: .system).then {
        $0.setTitle("비밀번호 확인", for: .normal)
        $0.layer.cornerRadius = 0
        $0.isEnabled = false
    }
    
    init(viewModel: ResetPWViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        responseToKeyboardHegiht(confirmButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setupBinding() {
        passwordInputTextFieldView.textField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self,
                      let text = self.passwordInputTextFieldView.textField.text
                else { return }
                self.viewModel.confirmPassword(password: text)
            })
            .disposed(by: disposeBag)
        
        viewModel.confirmPWHandler
            .bind(onNext: { [weak self] isSuccess in
                guard let self else { return }
                if isSuccess {
                    self.navigationController?.pushViewController(ResetPWViewController(self.viewModel), animated: true)
                } else {
                    self.notiAlert("비밀번호가 일치하지 않습니다.\n비밀번호를 확인해주세요.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func addSubView() {
        [titleLabel, subTitleLabel, passwordInputTextFieldView, confirmButton].forEach {
            self.view.addSubview($0)
        }
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
        
        self.confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
    }
}
