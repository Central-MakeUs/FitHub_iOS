//
//  TopTabbarItem.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/20.
//

import UIKit

final class TopTabbarItem: UIButton {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.setTitleColor(.textDefault, for: .normal)
            } else {
                self.setTitleColor(.textSub02, for: .normal)
            }
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        self.titleLabel?.font = .pretendard(.bodyLarge02)
    }
    
    //MARK: - Init
    init(_ title: String) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.setTitleColor(.textSub02, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
