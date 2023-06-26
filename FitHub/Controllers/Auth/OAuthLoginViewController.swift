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
        configure.baseForegroundColor = .textDefault
        configure.baseBackgroundColor = UIColor(red: 254/255, green: 229/255, blue: 0, alpha: 1)
        $0.configuration = configure
    }
    
    private let appleLoginButton = UIButton().then {
        var configure = UIButton.Configuration.filled()
        configure.title = "Apple로 계속하기"
        configure.image = UIImage(named: "apple")
        configure.imagePadding = 10
        configure.baseForegroundColor = .textDefault
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
        self.view.backgroundColor = .black
    }
    
    //MARK: - Bind
    override func setupBinding() {
        self.otherLoginButton.rx.tap
            .asDriver()
            .drive(onNext: {
                self.navigationController?.pushViewController(PhoneAuthViewController(PhoneAuthViewModel()), animated: true)
            })
            .disposed(by: self.disposeBag)
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

