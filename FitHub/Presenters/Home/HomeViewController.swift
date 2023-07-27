//
//  HomeViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit
import RxSwift

final class HomeViewController: BaseViewController {
    
    override func setupAttributes() {
        self.addNotificationCenter()
    }
    
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func ee() {
        
    }
}

extension HomeViewController {
    private func addNotificationCenter() {
        NotificationCenter.default.rx.notification(.presentAlert)
            .subscribe(onNext: { [weak self] notification in
                let authRepository = OAuthLoginRepository(AuthService())
                let authVC = UINavigationController(rootViewController: OAuthLoginViewController(
                    OAuthLoginViewModel(OAuthLoginUseCase(authRepository))))
                authVC.modalPresentationStyle = .fullScreen
                
                self?.present(authVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
