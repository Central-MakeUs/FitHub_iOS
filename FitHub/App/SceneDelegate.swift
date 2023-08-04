//
//  SceneDelegate.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/25.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        window?.rootViewController = setTapbar()
        window?.makeKeyAndVisible()
        
        UITextField.appearance().overrideUserInterfaceStyle = .dark
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
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
                                                                     certificationService: CertificationService()))
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

