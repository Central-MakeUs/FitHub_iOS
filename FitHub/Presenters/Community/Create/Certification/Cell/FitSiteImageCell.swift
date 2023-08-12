//
//  FitSiteImageCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/11.
//

import UIKit

final class FitSiteImageCell: UICollectionViewCell {
    static let identifier = "FitSiteImageCell"
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    
    private let cameraImageView = UIImageView(image: UIImage(named: "ic_camera")).then {
        $0.tintColor = .iconEnabled
    }
    
    private let photoCountLabel = UILabel().then {
        $0.text = "0 / 10"
        $0.font = .pretendard(.labelSmall)
        $0.textColor = .textSub02
    }
    
    private let deleteImageView = UIImageView(image: UIImage(named: "CancelIcon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubViews()
        layout()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.iconEnabled.cgColor
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.borderColor = UIColor.iconEnabled.cgColor
        self.layer.borderWidth = 0
//        self.imageView.image = nil
        self.cameraImageView.isHidden = true
        self.photoCountLabel.isHidden = true
        self.deleteImageView.isHidden = true
    }
    
    func configureCell(image: UIImage?) {
        self.imageView.image = image
        deleteImageView.isHidden = false
        self.layer.borderWidth = 0
    }
    
    func configureCameraCell(isEnable: Bool, count: Int) {
        self.layer.borderWidth = 1
        self.cameraImageView.isHidden = false
        self.photoCountLabel.isHidden = false
        self.deleteImageView.isHidden = true

        self.photoCountLabel.text = "\(count) / 10"
        if isEnable {
            self.layer.borderColor = UIColor.iconEnabled.cgColor
            self.cameraImageView.tintColor = .iconEnabled
            self.photoCountLabel.textColor = .iconEnabled
        } else {
            self.layer.borderColor = UIColor.iconDisabled.cgColor
            self.cameraImageView.tintColor = .iconDisabled
            self.photoCountLabel.textColor = .iconDisabled
        }
    }
    
    // MARK: - SubViews
    private func addSubViews() {
        self.addSubview(imageView)
        self.addSubview(cameraImageView)
        self.addSubview(photoCountLabel)
        self.addSubview(deleteImageView)
    }
    
    private func layout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        cameraImageView.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.centerY)
            $0.centerX.equalToSuperview()
        }
        
        photoCountLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.centerY)
            $0.centerX.equalToSuperview()
        }
        
        deleteImageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(6)
        }
    }
}
