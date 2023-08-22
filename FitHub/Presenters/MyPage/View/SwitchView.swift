//
//  SwitchView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import UIKit

final class SwitchView: UIStackView {
    private let titleLabel = PaddingLabel(padding: .init(top: 12, left: 0, bottom: 12, right: 0)).then {
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textDefault
    }
    
    let switchButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_toggle_Off"), for: .normal)
    }
    
    init(title: String) {
        self.titleLabel.text = title
        
        super.init(frame: .zero)
        [titleLabel, switchButton].forEach {
            self.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        switchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(46)
            $0.height.equalTo(28)
        }
    }
    
    func configureTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func configureSwitch(isOn: Bool) {
        let image = isOn ? UIImage(named: "btn_toggle_On") : UIImage(named: "btn_toggle_Off")
        self.switchButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
