//
//  SportHeaderView.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/30.
//

import UIKit

final class SportHeaderView: UICollectionReusableView {
    static let identifier = "SportHeaderView"
    
    private let guideLabel = UILabel().then {
        let title = "운동 종목 선택*"
        var attrString = NSMutableAttributedString(string: title,
                                                   attributes: [ .font : UIFont.pretendard(.titleMedium),
                                                                 .foregroundColor : UIColor.textDefault])
        
        attrString.addAttribute(.foregroundColor, value: UIColor.error, range: (title as NSString).range(of: "*"))
        
        $0.attributedText = attrString
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(guideLabel)
        
        self.guideLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
