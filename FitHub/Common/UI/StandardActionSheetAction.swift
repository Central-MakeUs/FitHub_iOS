//
//  StandardActionSheetAction.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/13.
//

import UIKit

final class StandardActionSheetAction: UIButton {
    let handler: ((StandardActionSheetAction) -> Void)?
    
    let lineLayer = CALayer().then {
        $0.backgroundColor = UIColor.iconDisabled.cgColor
    }
    
    init(title: String?, handler: ((StandardActionSheetAction) -> Void)? = nil) {
        self.handler = handler
        
        super.init(frame: .zero)
        var configuration = UIButton.Configuration.plain()
        configuration.titleAlignment = .center
        configuration.title = title
        configuration.baseForegroundColor = .error
        configuration.buttonSize = .large
        configuration.contentInsets = .init(top: 20, leading: 0, bottom: 20, trailing: 0)
    
        self.configuration = configuration
        
        self.layer.addSublayer(lineLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.lineLayer.frame = .init(x: 0, y: 0, width: self.frame.width, height: 1)
    }
}
