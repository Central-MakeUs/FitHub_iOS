//
//  PhoneAuthViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//

import UIKit
import RxCocoa
import RxSwift

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
        $0.textField.isSecureTextEntry = true
        $0.placeholder = "비밀번호 입력"
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.removeObject(forKey: "targetView")
        UserDefaults.standard.removeObject(forKey: "targetPK")
    }
    
    //MARK: -SetupBinding
    override func setupBinding() {
        let input = PhoneAuthViewModel.Input(phoneNumberText: self.phoneNumberTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                             passwordText: self.passwordTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                             loginButtonTap: self.loginButton.rx.tap.asSignal(),
                                             registButtonTap: self.registButton.rx.tap.asSignal(),
                                             findPasswordButtonTap: self.findPasswordButton.rx.tap.asSignal())
        
        let output = self.viewModel.transform(input: input)
        
        output.phoneNumberText
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] (text, status) in
                guard let self else { return }
                self.phoneNumberTextFieldView.textField.text = text
                
                if text.count == 11 {
                    self.phoneNumberTextFieldView.verifyFormat(status)
                } else {
                    self.phoneNumberTextFieldView.verifyFormat(.ok)
                }
            })
            .disposed(by: disposeBag)
        
        output.loginEnable
            .asDriver(onErrorJustReturn: false)
            .drive(self.loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        
        output.loginPublisher
            .bind(onNext: { [weak self] res in
                guard let self else { return }
                switch res {
                case .success:
                    let tabBar = self.setTapbar()
                    self.changeRootViewController(tabBar)
                case .failure(let error):
                    print("실패")
                    self.responseAuthError(error)
                }
            })
            .disposed(by: disposeBag)
        
        output.registTap
            .emit(onNext: { [weak self] in
                self?.pushRegistViewController()
            })
            .disposed(by: disposeBag)
        
        output.findPasswordTap
            .emit(onNext: { [weak self] in
                self?.pushFindPasswordViewController()
            })
            .disposed(by: disposeBag)
    }
    
    private func responseAuthError(_ error: AuthError) {
        switch error {
        case .invalidURL:
            print("주소 오류")
        case .serverError:
            self.notiAlert("서버 오류")
        case .oauthFailed:
            print("소셜로그인 실패")
        case .unknownUser:
            self.didNotFoundUserInfoAlert()
        case .passwordFaild:
            self.notiAlert("잘못된 비밀번호 입니다.")
        }
    }
    
    //MARK: - 화면 이동
    private func pushFindPasswordViewController() {
        let usecase = FindPWUseCase(FindPWRepository(UserService()))
        let findPasswordVC = FindPWViewController(FindPWViewModel(usecase))
        self.navigationController?.pushViewController(findPasswordVC, animated: true)
    }
    
    private func pushRegistViewController() {
        let agreementVC = AgreementViewController(AgreementViewModel(AgreementUseCase(),
                                                                     registType: .Phone))
        self.navigationController?.pushViewController(agreementVC, animated: true)
    }
    
    private func didNotFoundUserInfoAlert() {
        let alert = StandardAlertController(title: "회원 정보가 없습니다.", message: "입력하신 회원 정보는 존재하지 않아요.\n회원가입을 진행할까요?")
        let cancel = StandardAlertAction(title: "닫기", style: .cancel)
        let regist = StandardAlertAction(title: "회원가입 하기", style: .basic) { _ in
            self.pushRegistViewController()
        }
        alert.addAction(cancel)
        alert.addAction(regist)
        
        self.present(alert, animated: false)
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
