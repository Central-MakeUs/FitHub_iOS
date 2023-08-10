//
//  CategoryCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import UIKit

final class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.nameLabel.backgroundColor = .bgSub01
                self.nameLabel.textColor = .primary
                self.nameLabel.layer.borderColor = UIColor.primary.cgColor
            } else {
                self.nameLabel.backgroundColor = .clear
                self.nameLabel.textColor = .textSub01
                self.nameLabel.layer.borderColor = UIColor.iconDisabled.cgColor
            }
        }
    }
    
    //MARK: - Properties
    let nameLabel = PaddingLabel(padding: .init(top: 6, left: 12, bottom: 6, right: 12)).then {
        $0.font = .pretendard(.labelLarge)
        $0.textColor = .textSub01
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.iconDisabled.cgColor
        $0.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.nameLabel)
        
        self.nameLabel.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel(_ name: String) {
        self.nameLabel.text = name
    }
}
