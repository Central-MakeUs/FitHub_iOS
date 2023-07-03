//
//  StandardAlertAction.swift
//  OnandOff
//
//  Created by 신상우 on 2023/02/18.
//

import UIKit

enum StandardAlertStyle {
    case cancel
    case basic
}

class StandardAlertAction: UIButton {
    let handler: ((StandardAlertAction) -> Void)?
    
    init(title: String?, style: StandardAlertStyle, handler: ((StandardAlertAction) -> Void)? = nil)  {
        self.handler = handler
        super.init(frame: .zero)

        switch style {
        case .cancel:
            self.backgroundColor = .iconDisabled
        case .basic:
            self.backgroundColor = .primary
        }
        self.setTitleColor(.textDefault, for: .normal)
        self.titleLabel?.font = .pretendard(.bodyLarge02)
        self.setTitle(title, for: .normal)
        self.addTarget(self, action: #selector(didClickAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector
    @objc private func didClickAction() {
        NotificationCenter.default.post(name: .dismissStandardAlert, object: nil)
        guard let handler = handler else { return }
        handler(self)
    }
}
