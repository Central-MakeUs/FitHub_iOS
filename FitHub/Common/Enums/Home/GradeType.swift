//
//  LevelColor.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/04.
//

import UIKit.UIColor

enum GradeType: String {
    case one = "우주먼지"
    case two = "성운"
    case three = "태양"
    case four = "블랙홀"
    case five = "은하"
    
    var color: UIColor {
        switch self {
        case .one:
            return UIColor(red: 210/255, green: 58/255, blue: 35/255, alpha: 1)
        case .two:
            return UIColor(red: 40/255, green: 104/255, blue: 194/255, alpha: 1)
        case .three:
            return UIColor(red: 255/255, green: 207/255, blue: 0/255, alpha: 1)
        case .four:
            return UIColor(red: 78/255, green: 52/255, blue: 134/255, alpha: 1)
        case .five:
            return UIColor(red: 31/255, green: 153/255, blue: 80/255, alpha: 1)
        }
    }
}
