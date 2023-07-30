//
//  SportFooterView.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/30.
//

import UIKit

final class SportFooterView: UICollectionReusableView {
    static let identifier = "SportFooterView"
    
    private let guideLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "부적절한 게시물이 등록될 경우 관리자에 의해 비노출 및 삭제 처리 될 수 있습니다."
        $0.font = .pretendard(.labelMedium)
        $0.textColor = .textInfo
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(guideLabel)
        
        self.guideLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
