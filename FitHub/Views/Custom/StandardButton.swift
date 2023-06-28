//
//  StandardButton.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//

import UIKit

final class StandardButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.backgroundColor = .primary
                self.setTitleColor(.textDefault, for: .normal)
            } else {
                self.backgroundColor = .neon100
                self.setTitleColor(.textDisabled, for: .normal)
            }
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.backgroundColor = .primary
        self.setTitleColor(.textDefault, for: .normal)
        self.titleLabel?.font = .pretendard(.bodyMedium02)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
