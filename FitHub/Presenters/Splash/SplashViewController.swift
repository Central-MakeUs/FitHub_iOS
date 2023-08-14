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
        if let _ = KeychainManager.read("accessToken") {
            viewModel.checkUserLoginStatus()
        } else {
            let tabBar = self.setTapbar()
            tabBar.modalPresentationStyle = .fullScreen
            self.present(tabBar, animated: true)
        }
    }
    
    override func setupBinding() {
        viewModel.checkStatusPublisher
            .subscribe(onNext:  { [weak self] hasLogin in
                guard let self else { return }
                
                if !hasLogin {
                    KeychainManager.delete(key: "accessToken")
                    KeychainManager.delete(key: "userId")
                }
                let tabBar = self.setTapbar()
                tabBar.modalPresentationStyle = .fullScreen
                self.present(tabBar, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func setTapbar() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = .bgDefault
        tabBarController.selectedIndex = 1
        tabBarController.tabBar.unselectedItemTintColor = .iconDisabled
        tabBarController.tabBar.tintColor = .white
        
        let homeUsecase = HomeUseCase(repository: HomeRepository(homeService: HomeService(),
                                                                 authService: AuthService()))
        let homeVC = UINavigationController(rootViewController: HomeViewController(HomeViewModel(usecase: homeUsecase)))
        homeVC.tabBarItem.image = UIImage(named: "HomeIcon")
        homeVC.tabBarItem.title = "홈"
        
        let communityVCUsecase = CommunityUseCase(CommunityRepository(AuthService(),
                                                                      certificationService: CertificationService(),
                                                                      articleService: ArticleService()))
        let communityVC = UINavigationController(rootViewController: CommunityViewController(CommunityViewModel(communityVCUsecase)))
        communityVC.tabBarItem.image = UIImage(named: "CommunityIcon")
        communityVC.tabBarItem.title = "커뮤니티"
        
        let lookUpVC = UINavigationController(rootViewController: LookUpViewController())
        lookUpVC.tabBarItem.image = UIImage(named: "LookUpIcon")
        lookUpVC.tabBarItem.title = "둘러보기"
        
        let myPageVC = UINavigationController(rootViewController: MyPageViewController())
        myPageVC.tabBarItem.image = UIImage(named: "MyPageIcon")
        myPageVC.tabBarItem.title = "마이핏허브"
        
        tabBarController.viewControllers = [homeVC, communityVC, lookUpVC, myPageVC]
        
        return tabBarController
    }
}
