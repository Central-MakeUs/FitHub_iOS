//
//  TopTabBarItemCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/06.
//

import UIKit

final class TopTabBarItemCell: UICollectionViewCell {
    static let identifier = "TopTabBarItemCell"
    
    override var isSelected: Bool {
        didSet {
            let color: UIColor = isSelected ? .textDefault : .textSub02
            self.titleLabel.textColor = color
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodyLarge02)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(text: String) {
        self.titleLabel.text = text
    }
    
    func getTitleFrameWidth() -> CGFloat {
        guard let width = titleLabel.text?.getTextContentSize(withFont: .pretendard(.bodyLarge02)).width else { return 0}
        return width
    }
}
