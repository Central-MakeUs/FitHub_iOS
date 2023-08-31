//
//  LookUpButton.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/29.
//

import UIKit

final class LookUpButton: UIButton {
    
    init(title: String?, image: UIImage?) {
        super.init(frame: .zero)
        var configure = UIButton.Configuration.plain()
        configure.background.cornerRadius = 40
        configure.background.backgroundColor = .bgDefault
        configure.title = title
        configure.attributedTitle?.font = .pretendard(.bodySmall02)
        configure.attributedTitle?.foregroundColor = .textDefault
        configure.image = image
        configure.imagePadding = 4
        configure.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        self.configuration = configure
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
