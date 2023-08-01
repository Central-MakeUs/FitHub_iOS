//
//  CertifyCardView.swift
//  FitHub
//
//  Created by SangWoo's MacBook on 2023/07/31.
//

import UIKit

final class CertifyCardView: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "인증 달성률"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyLarge02)
    }
    
    private let categoryLabel = PaddingLabel(padding: .init(top: 0, left: 4, bottom: 0, right: 4)).then {
        $0.text = "스포츠"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
        $0.layer.cornerRadius = 2
        $0.backgroundColor = .bgSub02
    }
    
    private let progressView = UIProgressView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
        $0.progressTintColor = .primary
        $0.backgroundColor = .bgSub02
    }
    
    private let infoButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "ic_info")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private let maxExPLabel = UILabel().then {
        $0.text = "/ 1200"
        $0.textColor = .textInfo
        $0.font = .pretendard(.bodySmall02)
    }

    private let expLabel = UILabel().then {
        $0.text = "800 "
        $0.textColor = .primary
        $0.font = .pretendard(.bodySmall02)
    }
    
    private let currentMonthCertificationTitle = UILabel().then {
        $0.text = "이번 달 인증 횟수"
        $0.font = .pretendard(.bodySmall01)
        $0.textColor = .textSub01
        $0.textAlignment = .center
    }
    
    private let continueCertificationDayTitle = UILabel().then {
        $0.text = "연속 인증 일수"
        $0.font = .pretendard(.bodySmall01)
        $0.textColor = .textSub01
        $0.textAlignment = .center
    }
    
    private let currentMonthCertificationCount = UILabel().then {
        $0.text = "0회"
        $0.font = .pretendard(.bodyMedium02)
        $0.textColor = .textDefault
        $0.textAlignment = .center
    }
    
    private let continueCertificationDay = UILabel().then {
        $0.text = "0일"
        $0.font = .pretendard(.bodyMedium02)
        $0.textColor = .textDefault
        $0.textAlignment = .center
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .bgSub02
    }

    //TODO: Model 받아서 뷰 데이터 입력
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .bgSub01
        self.layer.cornerRadius = 15
        
        self.addSubView()
        self.layout()
        
        progressView.progress = 0.8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubView() {
        [titleLabel, categoryLabel, progressView, maxExPLabel, expLabel, infoButton,
         currentMonthCertificationTitle, currentMonthCertificationCount,
         continueCertificationDayTitle, continueCertificationDay, dividerView].forEach {
            self.addSubview($0)
        }
    }
    
    private func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(15)
        }
        
        self.categoryLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(6)
        }
        
        self.progressView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.categoryLabel.snp.bottom).offset(30)
            $0.height.equalTo(10)
        }
        
        self.maxExPLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalTo(self.progressView.snp.top).offset(-5)
        }
        
        self.expLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.maxExPLabel.snp.leading)
            $0.bottom.equalTo(self.progressView.snp.top).offset(-5)
        }
        
        self.infoButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(15)
        }
        
        self.currentMonthCertificationTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalTo(self.snp.centerX)
            $0.top.equalTo(self.progressView.snp.bottom).offset(10)
        }
        
        self.currentMonthCertificationCount.snp.makeConstraints {
            $0.centerX.equalTo(self.currentMonthCertificationTitle)
            $0.top.equalTo(self.currentMonthCertificationTitle.snp.bottom).offset(3)
        }
        
        self.continueCertificationDayTitle.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.leading.equalTo(self.snp.centerX)
            $0.top.equalTo(self.progressView.snp.bottom).offset(10)
        }
        
        self.continueCertificationDay.snp.makeConstraints {
            $0.centerX.equalTo(self.continueCertificationDayTitle)
            $0.top.equalTo(self.continueCertificationDayTitle.snp.bottom).offset(3)
        }
        
        self.dividerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.continueCertificationDayTitle)
            $0.bottom.equalTo(self.continueCertificationDay.snp.bottom)
            $0.width.equalTo(1)
        }
    }
}
