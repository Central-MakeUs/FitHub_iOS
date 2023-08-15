//
//  LevelIconView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import UIKit

final class LevelIconView: UIView {
    private let imageView = UIImageView()
    
    private let gradeLabel = PaddingLabel(padding: .init(top: 4, left: 4, bottom: 4, right: 4)).then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
        $0.backgroundColor = .bgSub01
        $0.font = .pretendard(.labelSmall)
        $0.text = "레벨명"
    }
    
    init(item: FithubLevelList) {
        imageView.kf.setImage(with: URL(string: item.levelIconUrl))
        let grade = "Lv.\(item.level) \(item.levelName)"
        gradeLabel.text = grade
        gradeLabel.highlightGradeName(grade: item.levelName, highlightText: grade)
        super.init(frame: .zero)
        
        [imageView, gradeLabel].forEach {
            self.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(45)
            $0.centerX.top.equalToSuperview()
        }
        
        gradeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(13)
            $0.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
