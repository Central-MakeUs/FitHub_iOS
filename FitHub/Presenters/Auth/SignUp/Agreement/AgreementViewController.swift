//
//  AgreementViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/28.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SafariServices

final class AgreementViewController: BaseViewController {
    //MARK: - Propeties
    private let viewModel: AgreementViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "회원가입 전,\n약관 동의가 필요해요."
        $0.textColor = .textDefault
        $0.numberOfLines = 2
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let frameView = UIView().then {
        $0.backgroundColor = .bgSub01
        $0.layer.cornerRadius = 5
    }
    
    private let agreeAllButton = UIButton(type: .system).then {
        
        $0.setImage(UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private let agreeAllLabel = UILabel().then {
        $0.text = "약관 전체동의"
        $0.textColor = .textDefault
        $0.font = .pretendard(.titleMedium)
    }
    
    private lazy var privateAgreementView = AgreementView("개인정보 수집 및 이용에 동의합니다.", isRequired: true)
    
    private let useAgreementView = AgreementView("이용약관에 동의합니다.", isRequired: true)
    
    private let locationAgreementView = AgreementView("위치 기반 서비스 약관에 동의합니다.", isRequired: true)
    
    private let ageAgreementView = AgreementView("만 14세 이상 입니다.", isRequired: true).then {
        $0.disclosureButton.isHidden = true
    }
    
    private let marketingAgreementView = AgreementView("마케팅 정보 수신에 동의합니다.", isRequired: false)
    
    private lazy var agreementsStackView = UIStackView(arrangedSubviews: [privateAgreementView, useAgreementView, locationAgreementView, ageAgreementView, marketingAgreementView]).then {
        $0.axis = .vertical
        $0.spacing = 14
        $0.distribution = .fillEqually
    }
    
    private let nextButton = StandardButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
    }
    
    init(_ viewModel: AgreementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupBinding() {
        let input = AgreementViewModel.Input(privateTap: self.privateAgreementView.checkButton.rx.tap.asObservable(),
                                             useTap: self.useAgreementView.checkButton.rx.tap.asObservable(),
                                             locationTap: self.locationAgreementView.checkButton.rx.tap.asObservable(),
                                             ageTap: self.ageAgreementView.checkButton.rx.tap.asObservable(),
                                             marketingTap: self.marketingAgreementView.checkButton.rx.tap.asObservable(),
                                             allAgreementTap: self.agreeAllButton.rx.tap.asObservable())
        
        let output = self.viewModel.transform(input: input)
        
        output.isEnableNextButton
            .bind(to: self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.privateAgreement
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.privateAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.useAgreement
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.useAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.locationAgreement
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.locationAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.ageAgreement
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.ageAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.marketingAgreement
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.marketingAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.allAgreement
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.agreeAllButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        self.nextButton.rx.tap
            .bind { [weak self] in
                self?.pushRegistInfoViewController()
            }
            .disposed(by: disposeBag)
        
        privateAgreementView.disclosureButton.rx.tap
            .bind { [weak self] in
                self?.openTermOfUseContentWithSafari(urlString: "https://fithub-pro.notion.site/8cd486867f66444ea28a36cbe67d4883?pvs=4")
            }
            .disposed(by: disposeBag)
        
        useAgreementView.disclosureButton.rx.tap
            .bind { [weak self] in
                self?.openTermOfUseContentWithSafari(urlString: "https://fithub-pro.notion.site/ad824d4667a4464a88884eb9cb94a583")
            }
            .disposed(by: disposeBag)
        
        locationAgreementView.disclosureButton.rx.tap
            .bind { [weak self] in
                self?.openTermOfUseContentWithSafari(urlString: "https://fithub-pro.notion.site/fe5b8bae5f674605a86bc3f01bc17ebd?pvs=4")
            }
            .disposed(by: disposeBag)
        
        marketingAgreementView.disclosureButton.rx.tap
            .bind { [weak self] in
                self?.openTermOfUseContentWithSafari(urlString: "https://fithub-pro.notion.site/fce06470eb59435890a1aa5556b3ac66?pvs=4")
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - 화면 이동
    private func openTermOfUseContentWithSafari(urlString: String) {
        guard let termURL = URL(string: urlString)   else { return }

        let safariViewController = SFSafariViewController(url: termURL)
        safariViewController.modalPresentationStyle = .automatic
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    private func pushRegistInfoViewController() {
        let userInfo = self.viewModel.usecase.registUserInfo
        if self.viewModel.registType == .OAuth {
//            let usecase = OAuthRegistInputUseCase(registUserInfo: userInfo)
//            let oAuthRegistInputVC = OAuthRegistInputViewController(OAuthRegistInputViewModel(usecase))
            let usecase = ProfileSettingUseCase(repository: ProfileSettingRepository(UserService()),
                                                userInfo: userInfo)
            let profileSettingVC = ProfileSettingViewController(ProfileSettingViewModel(usecase,
                                                                                        registType: .OAuth))
            self.navigationController?.pushViewController(profileSettingVC, animated: true)
        } else {
            let usecase = RegistInfoUseCase(userInfo,
                                            repository: RegistInfoRepository(service: UserService()))
            self.navigationController?.pushViewController(RegistInfoInputViewController(RegistInfoViewModel(usecase)), animated: true)
        }
    }
    
    override func addSubView() {
        self.view.addSubview(self.frameView)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.nextButton)
        self.view.addSubview(self.agreementsStackView)
        
        self.frameView.addSubview(self.agreeAllButton)
        self.frameView.addSubview(self.agreeAllLabel)
    }
    
    override func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(15)
        }
        
        self.frameView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(50)
        }
        
        self.agreeAllButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
        }
        
        self.agreeAllLabel.snp.makeConstraints {
            $0.leading.equalTo(self.agreeAllButton.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }
        
        self.agreementsStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.frameView.snp.bottom).offset(20)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }
}
