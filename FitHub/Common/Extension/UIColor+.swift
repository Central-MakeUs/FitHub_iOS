//
//  UIColor+.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/25.
//

import UIKit

extension UIColor {
    static var primary: UIColor { return UIColor(named: "Primary") ?? UIColor() }
    static var secondary: UIColor { return UIColor(named: "Secondary") ?? UIColor() }
    static var success: UIColor { return UIColor(named: "Success") ?? UIColor() }
    static var warning: UIColor { return UIColor(named: "Warning") ?? UIColor() }
    static var error: UIColor { return UIColor(named: "Error") ?? UIColor() }
    static var info: UIColor { return UIColor(named: "Info") ?? UIColor() }
    
    // TextColor
    static var textDefault: UIColor { return UIColor(named: "Text_default") ?? UIColor() }
    static var textDisabled: UIColor { return UIColor(named: "Text_disabled") ?? UIColor() }
    static var textInfo: UIColor { return UIColor(named: "Text_info") ?? UIColor() }
    static var textSub01: UIColor { return UIColor(named: "Text_sub01") ?? UIColor() }
    static var textSub02: UIColor { return UIColor(named: "Text_sub02") ?? UIColor() }
    
    // BagkGround
    static var bgSub01: UIColor { return UIColor(named: "Bg_sub01") ?? UIColor() }
    static var bgSub02: UIColor { return UIColor(named: "Bg_sub02") ?? UIColor() }
    static var bgSub03: UIColor { return UIColor(named: "Bg_sub03") ?? UIColor() }
    static var bgDefault: UIColor { return UIColor(named: "Bg_default") ?? UIColor() }
    
    // Icon
    static var iconDefault: UIColor { return UIColor(named: "Icon_default") ?? UIColor() }
    static var iconDisabled: UIColor { return UIColor(named: "Icon_disabled") ?? UIColor() }
    static var iconEnabled: UIColor { return UIColor(named: "Icon_enabled") ?? UIColor() }
    static var iconSub: UIColor { return UIColor(named: "Icon_sub") ?? UIColor() }
    
    // Neon
    static var neon100: UIColor { return UIColor(named: "Neon100") ?? UIColor() }
}

