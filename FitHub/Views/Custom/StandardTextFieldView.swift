//
//  StandardTextFieldView.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//

import UIKit

final class StandardTextFieldView: UIView {
    //MARK: - Properties
    private let frameView = UIView().then {
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.iconDisabled.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.labelSmall)
        $0.textColor = .textDisabled
    }
    
    private let textField = UITextField().then {
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textSub01
    }
    
    private let statusImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "logo")
    }
    
    private let guideLabel = UILabel().then {
        $0.font = .pretendard(.labelMedium)
    }
    
    var placeholder: String? {
        didSet {
            self.textField.placeholder = placeholder
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
    
    //MARK: - AddSubView
    private func addSubView() {
        self.addSubview(self.frameView)
        self.addSubview(self.guideLabel)
        
        self.frameView.addSubview(self.titleLabel)
        self.frameView.addSubview(self.textField)
    }
    
    //MARK: - Layout
    private func layout() {
        self.frameView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(62)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.leading.top.equalTo(10)
        }
        
        self.textField.snp.makeConstraints {
            $0.leading.equalTo(10)
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        
        self.guideLabel.snp.makeConstraints {
            $0.leading.equalTo(10)
            $0.top.equalTo(self.frameView.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
}
