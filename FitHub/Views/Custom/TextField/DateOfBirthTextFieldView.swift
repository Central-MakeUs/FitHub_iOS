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
    
    private let frameView = UIView().then {
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.iconDisabled.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "생년월일 및 성별"
        $0.font = .pretendard(.labelSmall)
        $0.textColor = .textDisabled
    }
    
    private let dateOfBirthTextField = UITextField().then {
        $0.clearsOnInsertion = true
        $0.keyboardType = .numberPad
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textSub01
        $0.placeholder = "YYMMDD"
    }
    
    private let separatorLabel = UILabel().then {
        $0.text = "-"
        $0.textColor = .iconSub
        $0.font = .pretendard(.bodyMedium02)
    }
    
    private let sexNumberTextField = UITextField().then {
        $0.keyboardType = .numberPad
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textSub01
        $0.placeholder = "0"
    }
    
    private let statusImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "Check")
    }
    
    private let rightImageView = UIImageView().then {
        $0.image = UIImage(named: "Empty")
    }
    
    private let hiddenPWLabel = UILabel().then {
        $0.text = "••••••"
        $0.textColor = .textSub01
        $0.font = .pretendard(.bodyMedium02)
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
    
    //MARK: - Binding
    private func setupBinding() {
        dateOfBirthTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] text in
                self?.dateOfBirthTextField.text = String(text.prefix(6))

                if text.count >= 6 {
                    self?.sexNumberTextField.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        sexNumberTextField.rx.text.orEmpty
            .distinctUntilChanged() // 현재 요소와 다른 요소일 경우만 리턴해주는 연산자
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] text in
                self?.sexNumberTextField.text = String(text.prefix(1))
                
                if text.count >= 1 {
                    self?.sexNumberTextField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .withUnretained(self)
            .bind { (this,notification) in
                print("키보드 올라감")
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .withUnretained(self)
            .bind { (this,notification) in
                print("에러검증")
            }
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
        self.frameView.addSubview(self.statusImageView)
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
        
        self.statusImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
        
        self.guideLabel.snp.makeConstraints {
            $0.leading.equalTo(10)
            $0.top.equalTo(self.frameView.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
}
