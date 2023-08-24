//
//  OnboardingView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/24.
//

import UIKit

final class OnboardingView: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "핏허브에 어서오세요!"
        $0.font = .pretendard(.headLineSmall)
        $0.textColor = .textDefault
    }
    
    private let subTitleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "재미있고 내게 맞는 운동이 찾고 싶어\n우주를 떠돌다 지친 당신, 핏허브 행성에 잘 오셨어요!"
        $0.numberOfLines = 0
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    init(title: String, subTitle: String, image: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.backgroundColor = UIColor(patternImage: UIImage(named: image) ?? UIImage())
        
        [titleLabel, subTitleLabel].forEach {
            self.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(1.4)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
