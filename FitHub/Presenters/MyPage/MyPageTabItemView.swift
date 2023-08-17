//
//  MyPageTabItemView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/17.
//

import UIKit

final class MyPageTabItemView: UIStackView {
    private let titleLabel = PaddingLabel(padding: .init(top: 12, left: 0, bottom: 12, right: 0)).then {
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textDefault
    }
    
    private let disclosureImageView = UIImageView(image: UIImage(named: "Disclosure")?.withRenderingMode(.alwaysOriginal))
    
    var subLabel = UILabel().then {
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textSub02
        $0.isHidden = true
    }
    
    init(title: String) {
        self.titleLabel.text = title
        super.init(frame: .zero)
        [titleLabel, disclosureImageView, subLabel].forEach {
            self.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        disclosureImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
