//
//  SportCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/30.
//

import UIKit

final class SportCell: UICollectionViewCell {
    static let identifier = "SportCell"
    
    private let frameView = UIView().then {
        $0.layer.borderColor = UIColor.primary.cgColor
        $0.backgroundColor = .bgSub01
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .textSub01
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frameView.layer.cornerRadius = self.frame.width/2
    }
    
    func configureCell(item: CategoryDTO, selectedItem: CategoryDTO?) {
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
        
        if let selectedItem,
           selectedItem == item {
            self.updateSelection(true)
        } else {
            self.updateSelection(false)
        }
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
            $0.height.equalTo(self.frameView.snp.width)
        }
        
        self.imageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.frameView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
}
