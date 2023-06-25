//
//  UIFont+.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/25.
//

import UIKit

enum PretendardType: String {
    case semibold = "SemiBold"
    case medium = "Medium"
    case regular = "Regular"
}

extension UIFont {
    static func pretendard(_ size: CGFloat, family: PretendardType = .regular) -> UIFont {
        return UIFont(name: "Pretendard-\(family.rawValue)", size: size) ?? UIFont()
    }
}
