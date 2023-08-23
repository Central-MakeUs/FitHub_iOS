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
    
    func changeRootViewController(_ rootViewController: UIViewController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = rootViewController
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        } else {
            rootViewController.modalPresentationStyle = .overFullScreen
            self.present(rootViewController, animated: true, completion: nil)
        }
    }
    
    func setTapbar() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = .bgDefault
        tabBarController.selectedIndex = 1
        tabBarController.tabBar.unselectedItemTintColor = .iconDisabled
        tabBarController.tabBar.tintColor = .white
        
        let homeUsecase = HomeUseCase(repository: HomeRepository(homeService: HomeService(),
                                                                 authService: UserService()))
        let homeVC = UINavigationController(rootViewController: HomeViewController(HomeViewModel(usecase: homeUsecase)))
        homeVC.tabBarItem.image = UIImage(named: "HomeIcon")
        homeVC.tabBarItem.title = "홈"
        
        let communityVCUsecase = CommunityUseCase(CommunityRepository(UserService(),
                                                                      certificationService: CertificationService(),
                                                                      articleService: ArticleService()),
                                                  homeRepo: HomeRepository(homeService: HomeService(),
                                                                           authService: UserService()))
        let communityVC = UINavigationController(rootViewController: CommunityViewController(CommunityViewModel(communityVCUsecase)))
        communityVC.tabBarItem.image = UIImage(named: "CommunityIcon")
        communityVC.tabBarItem.title = "커뮤니티"
        
        let lookUpVC = UINavigationController(rootViewController: LookUpViewController())
        lookUpVC.tabBarItem.image = UIImage(named: "LookUpIcon")
        lookUpVC.tabBarItem.title = "둘러보기"
        
        let myPageUsecase = MyPageUseCase(mypageRepository: MyPageRepository(service: UserService()),
                                          homeRepository: HomeRepository(homeService: HomeService(),
                                                                         authService: UserService()))
        let myPageVC = UINavigationController(rootViewController: MyPageViewController(viewModel: MyPageViewModel(usecase: myPageUsecase)))
        
        myPageVC.tabBarItem.image = UIImage(named: "MyPageIcon")
        myPageVC.tabBarItem.title = "마이핏허브"
        
        let exceptionVC = ExceptionViewController(title: "아직 준비중이에요!",
                                                  subTitle: "핏허브에서 열심히 공사중이니 조금만 기다려주시면 감사하겠습니다!")
        exceptionVC.navigationItem.leftBarButtonItem = nil
        let readyVC = UINavigationController(rootViewController: exceptionVC)
                                             
        readyVC.tabBarItem.image = UIImage(named: "LookUpIcon")
        readyVC.tabBarItem.title = "둘러보기"
        
        tabBarController.viewControllers = [homeVC, communityVC, readyVC, myPageVC]
        
        return tabBarController
    }
}
