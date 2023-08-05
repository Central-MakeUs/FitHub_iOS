//
//  MyPageViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit
import RxSwift
import RxCocoa

final class MyPageViewController: BaseViewController {
    private let logoutButton = UIButton().then {
        $0.setTitle("임시로그아웃", for: .normal)
    }
    
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    override func addSubView() {
        view.addSubview(logoutButton)
    }
    
    override func layout() {
        logoutButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func setupBinding() {
        logoutButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                KeychainManager.delete(key: "accessToken")
                self?.notiAlert("로그아웃 되었습니다.")
            })
            .disposed(by: disposeBag)
    }
}
