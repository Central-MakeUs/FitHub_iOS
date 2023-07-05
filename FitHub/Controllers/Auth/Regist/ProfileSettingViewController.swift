//
//  ProfileSettingViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileSettingViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: ProfileSettingViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "프로필 설정"
        $0.textColor = .textDefault
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "나를 표현할 사진과 닉네임을 등록해주세요."
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodyMedium01)
    }
    
    private let profileEditButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "DefaultProfile")?.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.layer.cornerRadius = 60
        $0.layer.masksToBounds = true
    }
    
    private let cameraImageView = UIImageView().then {
        $0.image = UIImage(named: "ProfileCamera")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let nickNameTextFieldView = StandardTextFieldView("닉네임").then {
        $0.placeholder = "닉네임 입력"
    }
    
    private let nextButton = StandardButton().then {
        $0.setTitle("다음", for: .normal)
        $0.isEnabled = false
    }
    
    //MARK: - Init
    init(_ viewModel: ProfileSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        let input = ProfileSettingViewModel.Input(nickNameText: self.nickNameTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                                  nextTap: self.nextButton.rx.tap.asSignal())
        
        let output = self.viewModel.transform(input: input)
        
        output.nickNameText
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.nickNameTextFieldView.textField.rx.text)
            .disposed(by: disposeBag)
  
        output.nickNameStatus
            .asDriver(onErrorJustReturn: .nickNameOK)
            .drive(onNext: { [weak self] status in
                self?.nickNameTextFieldView.verifyFormat(status)
                if status == .nickNameSuccess {
                    self?.nextButton.isEnabled = true
                } else {
                    self?.nextButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        output.nextTap
            .emit(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController?.pushViewController(SportsSelectingViewController(SportsSelectingViewModel(self.viewModel.userInfo)), animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.profileEditButton)
        self.view.addSubview(self.cameraImageView)
        self.view.addSubview(self.nickNameTextFieldView)
        self.view.addSubview(self.nextButton)
    }
    
    //MARK: - layout
    override func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
        }
        
        self.subTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.profileEditButton.snp.makeConstraints {
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(45)
            $0.height.width.equalTo(120)
            $0.centerX.equalToSuperview()
        }
        
        self.cameraImageView.snp.makeConstraints {
            $0.bottom.trailing.equalTo(self.profileEditButton)
            $0.height.width.equalTo(36)
        }
        
        self.nickNameTextFieldView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.profileEditButton.snp.bottom).offset(27)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
    }
}
