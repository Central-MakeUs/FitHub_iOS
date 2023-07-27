//
//  ViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import AuthenticationServices
import KakaoSDKUser
import RxKakaoSDKUser

final class OAuthLoginViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: OAuthLoginViewModel
    
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "logo_sub")
    }
    
    private let kakaoLoginButton = UIButton().then {
        var configure = UIButton.Configuration.filled()
        configure.title = "카카오로 3초 만에 시작하기"
        configure.image = UIImage(named: "kakao")
        configure.imagePadding = 10
        configure.baseForegroundColor = .black
        configure.baseBackgroundColor = UIColor(red: 254/255, green: 229/255, blue: 0, alpha: 1)
        $0.configuration = configure
    }
    
    private let appleLoginButton = UIButton().then {
        var configure = UIButton.Configuration.filled()
        configure.title = "Apple로 계속하기"
        configure.image = UIImage(named: "apple")
        configure.imagePadding = 10
        configure.baseForegroundColor = .black
        configure.baseBackgroundColor = .white
        $0.configuration = configure
    }
    
    private let otherLoginButton = UIButton().then {
        var configure = UIButton.Configuration.plain()
        var attribute = AttributedString.init("전화번호로 로그인 / 회원가입")
        attribute.font = .pretendard(.bodyMedium01)
        attribute.foregroundColor = .textDisabled
        attribute.underlineStyle = .single
        attribute.underlineColor = .textDisabled
        
        configure.attributedTitle = attribute
        
        $0.configuration = configure
    }
    
    //MARK: - Init
    init(_ viewModel: OAuthLoginViewModel) {
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
    
    //MARK: - ConfigureUI
    override func configureUI() {
        self.view.backgroundColor = .bgDefault
        self.navigationItem.leftBarButtonItem = nil
    }
    
    private func signInWithKakao() {
        UserApi.shared.logout() { _ in }
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.requestLogin()
                },
                onError: { [weak self] error in
                    self?.viewModel.loginPublisher.onError(error)
                })
            .disposed(by: disposeBag)
        } else {
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.requestLogin()
                },
                onError: { [weak self] error in
                    self?.viewModel.loginPublisher.onError(error)
                })
            .disposed(by: disposeBag)
        }
    }
    
    //MARK: - Bind
    override func setupBinding() {
        self.otherLoginButton.rx.tap
            .asDriver()
            .drive(onNext: {
                let usecase = PhoneNumLoginUseCase(PhoneNumLoginRepository(AuthService()))
                self.navigationController?.pushViewController(PhoneAuthViewController(PhoneAuthViewModel(usecase)), animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.appleLoginButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.signInWithApple()
            })
            .disposed(by: disposeBag)
        
        self.kakaoLoginButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.signInWithKakao()
            })
            .disposed(by: disposeBag)
        
        self.viewModel.loginPublisher
            .subscribe( onNext: { [weak self] res in
                guard let self else { return }
                switch res {
                case .success(let response):
                    if response.isLogin {
                        self.navigationController?.dismiss(animated: true)
                    } else {
                        self.showUserInfoNotFoundAlert()
                    }
                case .failure(let error):
                    // TODO: 외 에러
                    self.responseAuthError(error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showUserInfoNotFoundAlert() {
        let alert = StandardAlertController(title: "회원 정보가 없습니다.", message: "입력하신 회원 정보는 존재하지 않아요.\n회원가입을 진행할까요?")
        let cancel = StandardAlertAction(title: "닫기", style: .cancel) { _ in
            UserApi.shared.logout {_ in} // 카카오 로그아웃
        }
        let regist = StandardAlertAction(title: "회원가입 하기", style: .basic) { _ in
            // TODO: OAuth 회원가입 화면 이동
            print("regist")
        }
        alert.addAction(cancel)
        alert.addAction(regist)
        
        self.present(alert, animated: false)
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
            print("회원정보 없음")
        default:
            print("기타오류")
        }
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.logoImageView)
        self.view.addSubview(self.kakaoLoginButton)
        self.view.addSubview(self.appleLoginButton)
        self.view.addSubview(self.otherLoginButton)
    }
    
    //MARK: - Layout
    override func layout() {
        self.logoImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(84)
            $0.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        self.kakaoLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(self.appleLoginButton.snp.top).offset(-14)
        }
        
        self.appleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(self.otherLoginButton.snp.top).offset(-15)
        }
        
        self.otherLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-77)
        }
    }
}

extension OAuthLoginViewController: ASAuthorizationControllerDelegate {
    func signInWithApple() {
        let appleProvider = ASAuthorizationAppleIDProvider()
        let request = appleProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        self.viewModel.requestLogin(credential)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.viewModel.loginPublisher.onNext(.failure(AuthError.oauthFailed))
    }
}
