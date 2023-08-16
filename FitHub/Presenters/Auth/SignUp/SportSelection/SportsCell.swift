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
    override var isSelected: Bool {
        didSet {
            self.updateSelection(isSelected)
        }
    }
    private let frameView = UIView().then {
        $0.layer.cornerRadius = itemWidth / 2
        $0.layer.borderColor = UIColor.primary.cgColor
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
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: CategoryDTO) {
        do {
            if let urlString = item.imageUrl,
               let url = URL(string: urlString) {
                let data = try Data(contentsOf: url)
                self.imageView.image = UIImage(data: data)
            }
        } catch {
            print(error)
        }
        
        self.titleLabel.text = item.name
    }
    
    private func updateSelection(_ isSelected: Bool) {
        if isSelected {
            self.frameView.backgroundColor = .bgSub02
            self.frameView.layer.borderWidth = 1
        } else {
            self.frameView.backgroundColor = .bgSub01
            self.frameView.layer.borderWidth = 0
        }
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
            $0.height.equalTo(SportsCell.itemWidth)
        }
        
        self.imageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.frameView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
    }
}
