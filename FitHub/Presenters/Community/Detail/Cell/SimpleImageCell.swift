//
//  SimpleImageCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import UIKit

final class SimpleImageCell: UICollectionViewCell {
    static let identifier = "SimpleImageCell"
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: PictureList) {
        imageView.kf.setImage(with: URL(string: item.pictureUrl))
    }
}
