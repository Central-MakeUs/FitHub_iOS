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
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func notiAlert(_ content: String) {
        let alert = StandardNotificationAlertView(content)
        self.view.addSubview(alert)
        alert.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(38)
            $0.centerY.equalToSuperview()
        }
    }
}
