//
//  EmptyResultView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/16.
//

import UIKit

final class EmptyResultView: UIView {
    private let titleLabel = UILabel().then {
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyLarge02)
        $0.text = "''에 대한 검색 결과가 없어요."
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "다른 검색어를 입력해보세요!"
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodyMedium01)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(62)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel(text: String) {
        self.titleLabel.text = "'\(text)''에 대한 검색 결과가 없습니다."
    }
}
