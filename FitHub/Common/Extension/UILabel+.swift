//
//  UILabel+.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/04.
//

import UIKit.UILabel

extension UILabel {
    func highlightGradeName(grade: String, highlightText: String) {
        guard let content = self.text,
              let color = GradeType(rawValue: grade)?.color else { return }
        
        let attributedStr = NSMutableAttributedString(string: content)
        attributedStr.addAttribute(.foregroundColor, value: color, range: (content as NSString).range(of: highlightText))
        
        self.attributedText = attributedStr
    }
}

