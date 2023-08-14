//
//  ExpandTextView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import UIKit

final class ExpandTextView: UITextView {
    var canResign: Bool = true
    
    override var canResignFirstResponder: Bool {
        return canResign
    }
}
