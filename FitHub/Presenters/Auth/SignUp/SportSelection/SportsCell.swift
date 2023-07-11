//
//  SportsCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import UIKit

final class SportsCell: UICollectionViewCell {
    static let identifier = "SportsCell"
    static let itemWidth = (UIScreen.main.bounds.width - 40 - 16) / 3
    
    //MARK: - Properties
    private let frameView = UIView().then {
        $0.layer.cornerRadius = itemWidth / 2
        $0.backgroundColor = .bgSub01
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .textDefault
        $0.numberOfLines = 0
        $0.font = .pretendard(.bodyMedium01)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: String) {
        self.titleLabel.text = item
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.addSubview(self.frameView)
        self.addSubview(self.titleLabel)
        
        self.frameView.addSubview(self.imageView)
    }
    
    //MARK: - Layout
    private func layout() {
        self.frameView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().inset(1)
            $0.height.equalTo(106)
        }
        
        self.imageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.frameView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
    }
}
