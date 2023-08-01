//
//  HomeViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit
import RxSwift

final class HomeViewController: BaseViewController {
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "은하 댕우님,\n오늘도 힘내서 운동해봐요!"
        $0.font = .pretendard(.titleLarge)
        $0.textColor = .textDefault
    }
    
    private let certificationButton = UIButton(type: .system).then {
        $0.setTitleColor(.textSub01, for: .normal)
        $0.setTitle("운동인증하러가기", for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
    }
    
    private let levelImageView = UIImageView().then {
        $0.image = UIImage(named: "DefaultProfile")
        $0.contentMode = .scaleAspectFit
    }
    
    private let certifyCardView = CertifyCardView()
    
    override func setupAttributes() {
        self.addNotificationCenter()
    }
    
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "logo_basic")))
        
        let noti = UIBarButtonItem(image: UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal),
                                   style: .plain, target: nil, action: nil)
        let bookmark = UIBarButtonItem(image: UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal),
                                       style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [noti,bookmark]
        
    }
    
    override func addSubView() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(certificationButton)
        self.view.addSubview(levelImageView)
        self.view.addSubview(certifyCardView)
    }
    
    override func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
        }
        
        self.certificationButton.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.levelImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.width.height.equalTo(80)
        }
        
        self.certifyCardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.certificationButton.snp.bottom).offset(33)
            $0.height.equalTo(167)
        }
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
