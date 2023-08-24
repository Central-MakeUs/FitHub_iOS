//
//  SplashViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/05.
//

import UIKit
import RxCocoa
import RxSwift

final class SplashViewController: BaseViewController {
    private let viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let showOnBoarding = UserDefaults.standard.object(forKey: "showOnBoarding") as? Bool,
           !showOnBoarding  {
            viewModel.checkUserLoginStatus()
        } else {
            showOnboardingVC()
        }
    }
    
    override func setupBinding() {
        viewModel.checkStatusPublisher
            .subscribe(onNext:  { [weak self] hasLogin in
                guard let self else { return }
                if !hasLogin {
                    let usecase = OAuthLoginUseCase(OAuthLoginRepository(UserService()))
                    let authVC = UINavigationController(rootViewController: OAuthLoginViewController(
                        OAuthLoginViewModel(usecase)))
                    self.changeRootViewController(authVC)
                } else {
                    let tabBar = self.setTapbar()
                    self.changeRootViewController(tabBar)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.errorHandler
            .bind(onNext: { [weak self] error in
                print(error.localizedDescription)
                let exceptionVC = ExceptionViewController(title: "오류가 발생하였습니다.",
                                                          subTitle: "잠시 후 다시 시도해 주세요!")
                exceptionVC.navigationItem.leftBarButtonItem = nil
                let errorVC = UINavigationController(rootViewController: exceptionVC)
                errorVC.modalPresentationStyle = .fullScreen
                self?.present(errorVC, animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func showOnboardingVC() {
        let onboardingVC = OnBoardingViewController()
        self.present(onboardingVC, animated: true)
    }
}
