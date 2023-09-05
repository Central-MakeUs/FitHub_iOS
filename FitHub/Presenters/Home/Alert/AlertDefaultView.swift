//
//  AlertDefaultView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/23.
//

import UIKit

final class AlertDefaultView: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "새로운 알림이 없습니다."
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textDefault
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "새로운 알림이 오면 알려드릴게요."
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubViews() {
        [titleLabel,subTitleLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(160)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
