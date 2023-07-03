//
//  PaddingLabel.swift
//  OnandOff
//
//  Created by 신상우 on 2023/02/18.
//

import UIKit

final class PaddingLabel: UILabel {
    var top: CGFloat = 0
    var bottom: CGFloat = 0
    var left: CGFloat = 0
    var right: CGFloat = 0
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.top = padding.top
        self.left = padding.left
        self.bottom = padding.bottom
        self.right = padding.right
    }
    
    override func drawText(in rect: CGRect) {
        let inset = UIEdgeInsets(top: self.top, left: self.left, bottom: self.bottom, right: self.right)
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + self.left + self.right,
                      height: size.height + self.top + self.bottom)
    }
}
