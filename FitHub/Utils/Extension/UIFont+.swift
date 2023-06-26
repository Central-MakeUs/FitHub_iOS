//
//  UIFont+.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/25.
//

import UIKit

public enum PretendardType {
    case headLineSmall
    case headLineMedium
    case headLineLarge
    case titleSmall
    case titleMedium
    case titleLarge
    case bodySmall01
    case bodySmall02
    case bodyMedium01
    case bodyMedium02
    case bodyLarge01
    case bodyLarge02
    case labelSmall
    case labelMedium
    case labelLarge
    
    var family: String {
        switch self {
        case .headLineSmall, .headLineMedium, .headLineLarge, .titleMedium, .titleLarge:
            return "SemiBold"
        case .titleSmall, .bodySmall01, .bodyMedium01, .bodyLarge01, .labelSmall, .labelMedium , .labelLarge:
            return "Regular"
        case .bodySmall02, .bodyMedium02, .bodyLarge02:
            return "Medium"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .headLineSmall: return 24
        case .headLineMedium: return 28
        case .headLineLarge: return 32
        case .titleMedium: return 18
        case .titleLarge: return 22
        case .titleSmall, .bodyMedium01, .bodyMedium02, .labelLarge: return 14
        case .bodySmall01, .bodySmall02, .labelMedium: return 12
        case .bodyLarge01, .bodyLarge02: return 16
        case .labelSmall: return 11
        }
    }
    
    var lineSpace: CGFloat {
        switch self {
        case .headLineSmall: return 32
        case .headLineMedium: return 36
        case .headLineLarge: return 40
        case .titleLarge: return 28
        case .titleSmall, .bodyMedium01, .bodyMedium02, .labelLarge: return 20
        case .titleMedium, .bodyLarge01, .bodyLarge02: return 24
        case .bodySmall01, .bodySmall02, .labelSmall, .labelMedium: return 16
        }
    }
}

extension UIFont {
    static func pretendard(_ type: PretendardType) -> UIFont {
        print("Pretendard-\(type.family)")
        return UIFont(name: "Pretendard-\(type.family)", size: type.size) ?? UIFont()
    }
}
