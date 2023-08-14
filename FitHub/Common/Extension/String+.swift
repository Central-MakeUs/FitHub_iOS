//
//  String+.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/07.
//

import UIKit

extension String {
    func getTextContentSize(withFont font: UIFont) -> CGSize {
        let label = UILabel()
        label.font = font
        label.text = self
        return label.intrinsicContentSize
    }
}
