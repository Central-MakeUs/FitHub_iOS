//
//  FacilityCard.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/30.
//

import UIKit

final class FacilityCard: UIView {
    private let imageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "location_photo box_90px")
    }
    
    private let sportLabel = PaddingLabel(padding: .init(top: 4, left: 4, bottom: 4, right: 4)).then {
        $0.font = .pretendard(.labelSmall)
        $0.textColor = .textSub02
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub02
    }
    
    private let dividerLine = UIView().then {
        $0.backgroundColor = .bgSub02
    }
    
    private let distanceLabel = UILabel().then {
        $0.textColor = .primary
        $0.font = .pretendard(.bodySmall02)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textDefault
    }
    
    private let addressLabel = UILabel().then {
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    private let phoneNumLabel = UILabel().then {
        $0.font = .pretendard(.labelLarge)
        $0.textColor = .textSub02
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        layout()
        
        self.layer.cornerRadius = 10
        self.backgroundColor = .bgDefault
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureItem(item: FacilityDTO) {
        if let url = item.imageUrl {
            imageView.kf.setImage(with: URL(string: url))
        } else {
            imageView.image = UIImage(named: "location_photo box_90px")
        }
        sportLabel.text = item.category
        distanceLabel.text = item.dist
        titleLabel.text = item.name
        addressLabel.text = item.roadAddress
        phoneNumLabel.text = item.phoneNumber
    }
    
    private func addSubViews() {
        [imageView, sportLabel, dividerLine, distanceLabel,titleLabel,addressLabel,phoneNumLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func layout() {
        imageView.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview().inset(20)
            $0.height.width.equalTo(90)
        }
        
        sportLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(10)
            $0.top.equalTo(imageView)
        }
        
        dividerLine.snp.makeConstraints {
            $0.centerY.equalTo(sportLabel)
            $0.height.equalTo(sportLabel).multipliedBy(0.6)
            $0.leading.equalTo(sportLabel.snp.trailing).offset(10)
            $0.width.equalTo(1)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.leading.equalTo(dividerLine.snp.trailing).offset(10)
            $0.centerY.equalTo(sportLabel)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(sportLabel)
            $0.top.equalTo(sportLabel.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        addressLabel.snp.makeConstraints {
            $0.leading.equalTo(sportLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        phoneNumLabel.snp.makeConstraints {
            $0.leading.equalTo(sportLabel)
            $0.top.equalTo(addressLabel.snp.bottom).offset(2)
        }
    }
}
