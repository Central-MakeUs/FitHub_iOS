//
//  UICollectionView+.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/30.
//

import UIKit

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}


