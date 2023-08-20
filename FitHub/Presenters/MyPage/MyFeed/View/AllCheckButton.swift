//
//  AllCheckButton.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import UIKit

final class AllCheckButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            let image = isSelected ? UIImage(named: "CheckOn") : UIImage(named: "CheckOff")
            self.configuration?.image = image?.withRenderingMode(.alwaysOriginal)
            self.configuration?.background.backgroundColor = .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var configure = UIButton.Configuration.plain()
        configure.title = "전체선택"
        configure.attributedTitle?.font = .pretendard(.bodyMedium02)
        configure.attributedTitle?.foregroundColor = .textDefault
        configure.image = UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal)
        configure.imagePadding = 5
        configure.contentInsets = .zero
        
        self.configuration = configure
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
