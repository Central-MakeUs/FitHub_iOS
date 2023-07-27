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
                self.setTitleColor(.bgDefault, for: .normal)
            } else {
                self.backgroundColor = .neon100
                self.setTitleColor(.bgDefault, for: .normal)
            }
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        self.titleLabel?.font = .pretendard(.bodyLarge02)
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.backgroundColor = .primary
        self.setTitleColor(.bgDefault, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
