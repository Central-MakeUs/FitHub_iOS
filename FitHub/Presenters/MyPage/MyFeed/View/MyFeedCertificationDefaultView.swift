//
//  MyFeedCertificationDefaultView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import UIKit

final class MyFeedDefaultView: UIView {
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "운동 인증 이력이 없습니다."
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyLarge02)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
        $0.text = "오늘의 운동을 인증해보세요."
    }
    
    let moveButton = UIButton().then {
        var configure = UIButton.Configuration.bordered()
        configure.contentInsets = .init(top: 10, leading: 14, bottom: 10, trailing: 14)
        configure.baseForegroundColor = .black
        configure.background.backgroundColor = .primary
        configure.background.cornerRadius = 20
        configure.title = "인증 하러가기"
        configure.attributedTitle?.font = .pretendard(.bodyLarge02)
        
        $0.configuration = configure
    }
    
    init(title: String, subTitle: String, buttonName: String) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
        moveButton.configuration?.title = buttonName
        moveButton.configuration?.attributedTitle?.font = .pretendard(.bodyLarge02)
        super.init(frame: .zero)
        
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubViews() {
        [titleLabel, subTitleLabel, moveButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
        }
        
        moveButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(15)
        }
    }
}

