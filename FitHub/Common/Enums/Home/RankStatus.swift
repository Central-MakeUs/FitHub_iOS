//
//  RankStatus.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/04.
//

import UIKit

enum RankStatus: String {
    case keep = "KEEP"
    case up = "UP"
    case down = "DOWN"
    case new = "NEW"
    
    var image: UIImage? {
        switch self {
        case .keep:
            return UIImage(named: "ic_score_notchange")
        case .up:
            return UIImage(named: "ic_score_high")
        case .down:
            return UIImage(named: "ic_score_row")
        case .new:
            return UIImage(named: "score_new")
        }
    }
}
