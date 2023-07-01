//
//  StandardTextFieldView.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//

import UIKit
import RxSwift
import RxCocoa

final class StandardTextFieldView: UIView {
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    
    private let frameView = UIView().then {
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.iconDisabled.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.labelSmall)
        $0.textColor = .textDisabled
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .pretendard(.labelMedium)
        $0.textColor = .secondary
        $0.text = "3:00"
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [textField, statusImageView])
    
    let textField = UITextField().then {
        $0.clearButtonMode = .whileEditing
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textSub01
        
        if let clearButton = $0.value(forKeyPath: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(named: "CancelIcon"), for: .normal)
        }
    }
    
    private let statusImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "Empty")
    }
    
    private let guideLabel = UILabel().then {
        $0.font = .pretendard(.labelMedium)
    }
    
    var placeholder: String? {
        didSet {
            self.textField.placeholder = placeholder
        }
    }
    
    var text: String? {
        didSet {
            self.textField.text = text
        }
    }
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            self.textField.keyboardType = self.keyboardType
        }
    }
    
    var isTextFieldEnabled: Bool = true {
        didSet {
            self.textField.isEnabled = isTextFieldEnabled
        }
    }
    
    //MARK: - Init
    init(_ title: String) {
        self.titleLabel.text = title
        super.init(frame: .zero)
        
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Method
    func verifyFormat(_ status: UserInfoStatus) {
        switch status {
        case .notMatchPassword: fallthrough
        case .notValidDateOfBirth: fallthrough
        case .notValidPassword: fallthrough
        case .notValidPhoneNumber: fallthrough
        case .notValidSexNumber: fallthrough
        case .underage: fallthrough
        case .passwordLengthError:
            self.guideLabel.textColor = .error
            self.frameView.layer.borderColor = UIColor.error.cgColor
            self.statusImageView.image = UIImage(named: "Warning")
            self.guideLabel.text = status.message
            self.titleLabel.textColor = .error
        case .ok:
            self.frameView.layer.borderColor = UIColor.iconDisabled.cgColor
            self.statusImageView.image = UIImage(named: "Empty")
            self.guideLabel.textColor = .textSub02
            self.guideLabel.text = status.message
            self.titleLabel.textColor = .textDisabled
        case .success:
            self.frameView.layer.borderColor = UIColor.info.cgColor
            self.statusImageView.image = UIImage(named: "Check")
            self.guideLabel.textColor = .info
            self.guideLabel.text = status.message
            self.titleLabel.textColor = .info
        }
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.addSubview(self.frameView)
        self.addSubview(self.guideLabel)
        
        self.frameView.addSubview(self.titleLabel)
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
        
        self.stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        self.guideLabel.snp.makeConstraints {
            $0.leading.equalTo(10)
            $0.top.equalTo(self.frameView.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
}
