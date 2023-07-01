//
//  UIViewController+.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTapped(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
}
