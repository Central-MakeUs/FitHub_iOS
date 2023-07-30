//
//  HashTagFooterView.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/30.
//

import UIKit

class HashTagFooterView: UICollectionReusableView {
    static let identifier = "HashTagFooterView"
    
    private let guideLabel = UILabel().then {
        $0.text = "태그는 최대 4개까지 등록할 수 있어요."
        $0.font = .pretendard(.labelMedium)
        $0.textColor = .textInfo
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(guideLabel)
        self.addSubview(dividerView)
        
        self.guideLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
        }
        
        self.dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.guideLabel.snp.bottom).offset(30)
            $0.height.equalTo(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
