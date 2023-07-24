//
//  CertificationCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import UIKit

final class CertificationCell: UICollectionViewCell {
    static let identifier = "CertificationCell"
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = .iconDisabled
        $0.layer.cornerRadius = 5
    }
    
    private let likeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "ic_heart_default")?.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.backgroundColor = .clear
    }
    
    private let likeCntLabel = UILabel().then {
        $0.text = "-"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodySmall01)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(likeButton)
        self.contentView.addSubview(likeCntLabel)
    }
    
    //MARK: - Layout
    private func layout() {
        self.imageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.likeButton.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(10)
        }
        
        self.likeCntLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.likeButton)
            $0.leading.equalTo(self.likeButton.snp.trailing).offset(2)
        }
    }
}
