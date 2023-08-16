//
//  RecommendView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import UIKit
import RxSwift
import RxCocoa

final class RecommendView: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "추천 검색어"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyMedium02)
    }
    
    lazy var keywordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        $0.backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(keywordCollectionView)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
        }
        
        keywordCollectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecommendView {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(30),
                                              heightDimension: .absolute(32))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(32))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
