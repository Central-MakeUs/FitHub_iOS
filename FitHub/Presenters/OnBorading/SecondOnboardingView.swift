//
//  SecondOnboardingView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/24.
//

import UIKit

final class SecondOnboardingView: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "오운완 인증하고 레벨 UP!"
        $0.font = .pretendard(.headLineSmall)
        $0.textColor = .textDefault
    }
    
    private let subTitleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "인증샷 한 장으로 경험치가 쌓여요.\n우주먼지부터 은하까지 성장하면서 재밌게 운동해요!"
        $0.numberOfLines = 0
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(patternImage: UIImage(named: "onbording_2") ?? UIImage())
        
        [titleLabel, subTitleLabel].forEach {
            self.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(1.5)
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
