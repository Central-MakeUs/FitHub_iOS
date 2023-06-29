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
        $0.backgroundColor = .bgDeep
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
    
    private let ageAgreementView = AgreementView("만 14세 이상 입니다.", isRequired: true)
    
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
        //Input
        self.agreeAllButton.rx.tap
            .asDriver()
            .drive(onNext: {
                let isChecked = self.viewModel.allAgreementObserver.value
                self.viewModel.toggleAllCheck(!isChecked)
            })
            .disposed(by: disposeBag)
        
        self.privateAgreementView.checkButton.rx.tap
            .bind(onNext: {
                let newValue = !self.viewModel.privateAgreementObserver.value
                self.viewModel.privateAgreementObserver.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        self.useAgreementView.checkButton.rx.tap
            .bind(onNext: {
                let newValue = !self.viewModel.useAgreementObserver.value
                self.viewModel.useAgreementObserver.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        self.locationAgreementView.checkButton.rx.tap
            .bind(onNext: {
                let newValue = !self.viewModel.locationAgreementObserver.value
                self.viewModel.locationAgreementObserver.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        self.ageAgreementView.checkButton.rx.tap
            .bind(onNext: {
                let newValue = !self.viewModel.ageAgreementObserver.value
                self.viewModel.ageAgreementObserver.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        self.marketingAgreementView.checkButton.rx.tap
            .bind(onNext: {
                let newValue = !self.viewModel.marketingAgreementOberver.value
                self.viewModel.marketingAgreementOberver.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        //Output
        self.viewModel.isEnableNextButton
            .bind(to: self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.viewModel.privateAgreementObserver
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.privateAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.useAgreementObserver
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.useAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.locationAgreementObserver
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.locationAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.ageAgreementObserver
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.ageAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.marketingAgreementOberver
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.marketingAgreementView.checkButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.allAgreementObserver
            .bind(onNext: { isChecked in
                let img = isChecked ? UIImage(named: "CheckOn")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
                self.agreeAllButton.setImage(img, for: .normal)
            })
            .disposed(by: disposeBag)
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