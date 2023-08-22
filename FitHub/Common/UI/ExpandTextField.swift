//
//  ExpandTextField.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import UIKit

final class ExpandTextField: UITextField {
    var canResign: Bool = true
    
    override var canResignFirstResponder: Bool {
        return canResign
    }
}
