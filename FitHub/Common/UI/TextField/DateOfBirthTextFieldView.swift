//
//  DateOfBirthTextFieldView.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/29.
//

import UIKit
import RxSwift
import RxCocoa

final class DateOfBirthTextFieldView: UIView {
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private var status = UserInfoStatus.ok
    private var currentBorderColor = UIColor.iconDisabled.cgColor

    private let frameView = UIView().then {
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.iconEnabled.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "생년월일 및 성별"
        $0.font = .pretendard(.labelSmall)
        $0.textColor = .textDisabled
    }
    
    let dateOfBirthTextField = UITextField().then {
        $0.clearsOnInsertion = true
        $0.keyboardType = .numberPad
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textSub01
        $0.attributedPlaceholder = NSAttributedString(string: "YYMMDD",
                                                      attributes: [.foregroundColor : UIColor.textDisabled])
    }
    
    private let separatorLabel = UILabel().then {
        $0.text = "-"
        $0.textColor = .iconSub
        $0.font = .pretendard(.bodyMedium02)
    }
    
    let sexNumberTextField = UITextField().then {
        $0.keyboardType = .numberPad
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textSub01
        $0.attributedPlaceholder = NSAttributedString(string: "0",
                                                      attributes: [.foregroundColor : UIColor.textDisabled])
    }
    
    private let statusImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = nil
    }
    
    private let clearButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "CancelIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.isHidden = true
    }
    
    private let rightImageView = UIImageView().then {
        $0.image = UIImage(named: "Empty")
    }
    
    private let hiddenPWLabel = UILabel().then {
        $0.text = "••••••"
        $0.textColor = .textSub01
        $0.font = .pretendard(.bodyMedium02)
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [clearButton, statusImageView]).then {
        $0.distribution = .fillProportionally
        $0.spacing = 10
    }
    
    private let guideLabel = UILabel().then {
        $0.font = .pretendard(.labelMedium)
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
        self.setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Method
    func verifyFormat(_ status: UserInfoStatus) {
        self.status = status
        switch status {
        case .notMatchPassword: fallthrough
        case .notValidDateOfBirth: fallthrough
        case .notValidPassword: fallthrough
        case .notValidPhoneNumber: fallthrough
        case .notValidSexNumber: fallthrough
        case .underage: fallthrough
        case .duplicateNickName: fallthrough
        case .passwordLengthError:
            self.guideLabel.textColor = .error
            self.frameView.layer.borderColor = UIColor.error.cgColor
            self.statusImageView.image = UIImage(named: "Warning")
            self.guideLabel.text = status.message
            self.titleLabel.textColor = .error
            self.stackView.spacing = 10
            self.layoutIfNeeded()
        case .passwordOK: fallthrough
        case .nickNameOK: fallthrough
        case .ok:
            self.frameView.layer.borderColor = self.currentBorderColor
            self.statusImageView.image = nil
            self.guideLabel.textColor = .textSub02
            self.guideLabel.text = status.message
            self.titleLabel.textColor = .textDisabled
            self.stackView.spacing = 0
        case .passwordSuccess: fallthrough
        case .nickNameSuccess: fallthrough
        case .matchPassword:
            self.frameView.layer.borderColor = UIColor.info.cgColor
            self.statusImageView.image = UIImage(named: "Check")
            self.guideLabel.textColor = .info
            self.guideLabel.text = status.message
            self.titleLabel.textColor = .info
            self.stackView.spacing = 10
        }
    }
    
    //MARK: - SetupBinding
    private func setupBinding() {
        Observable.merge(dateOfBirthTextField.rx.controlEvent(.editingDidBegin).asObservable(),
                         sexNumberTextField.rx.controlEvent(.editingDidBegin).asObservable())
        .bind(onNext: { [weak self] _ in
            self?.clearButton.isHidden = false
            if self?.status == .ok {
                self?.currentBorderColor = UIColor.iconSub.cgColor
                self?.frameView.layer.borderColor = UIColor.iconSub.cgColor
            }
        })
        .disposed(by: disposeBag)
        let text = Observable.combineLatest(self.dateOfBirthTextField.rx.text.orEmpty,
                                            self.sexNumberTextField.rx.text.orEmpty)
            .map { $0 + $1 }
        
        Observable.merge(dateOfBirthTextField.rx.controlEvent(.editingDidEnd).asObservable(),
                         sexNumberTextField.rx.controlEvent(.editingDidEnd).asObservable())
        .withLatestFrom(text)
        .bind(onNext: { [weak self] text in
            self?.clearButton.isHidden = true

            if self?.status == .ok {
                let color = text.isEmpty ? UIColor.iconEnabled.cgColor : UIColor.iconDisabled.cgColor
                self?.currentBorderColor = color
                self?.frameView.layer.borderColor = color
            }
        })
        .disposed(by: disposeBag)
        
        let clearEvent = self.clearButton.rx.tap.share()
            .map { "" }
            
        clearEvent
            .bind(to: dateOfBirthTextField.rx.text)
            .disposed(by: disposeBag)
        
        clearEvent
            .bind(to: sexNumberTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.addSubview(self.frameView)
        self.addSubview(self.guideLabel)
    
        self.frameView.addSubview(self.titleLabel)
        self.frameView.addSubview(self.dateOfBirthTextField)
        self.frameView.addSubview(self.separatorLabel)
        self.frameView.addSubview(self.sexNumberTextField)
        self.frameView.addSubview(self.hiddenPWLabel)
        self.frameView.addSubview(self.stackView)
    }
    
    //MARK: - Layout
    private func layout() {
        self.frameView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(62)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(10)
        }
        
        self.dateOfBirthTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(self.separatorLabel.snp.leading).inset(-10)
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        self.separatorLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(-20)
            $0.centerY.equalTo(self.dateOfBirthTextField)
        }
    
        self.sexNumberTextField.snp.makeConstraints {
            $0.leading.equalTo(self.separatorLabel.snp.trailing).offset(10)
            $0.centerY.equalTo(self.separatorLabel)
        }
        
        self.hiddenPWLabel.snp.makeConstraints {
            $0.leading.equalTo(self.sexNumberTextField.snp.trailing).offset(8)
            $0.centerY.centerY.equalTo(self.dateOfBirthTextField)
        }
        
        self.stackView.setContentHuggingPriority(.required, for: .horizontal)
        self.stackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
        
        self.guideLabel.snp.makeConstraints {
            $0.leading.equalTo(10)
            $0.top.equalTo(self.frameView.snp.bottom).offset(3)
            $0.bottom.equalToSuperview()
        }
    }
}
