//
//  PrivacyInfoSettingViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/19.
//

import UIKit
import RxCocoa
import RxSwift

final class PrivacyInfoSettingViewController: BaseViewController {
    private let viewModel: MyPageViewModel
    
    private let nameInfoView = MyPageTabItemView(title: "이름")
    
    private let emailInfoView = MyPageTabItemView(title: "이메일")
    
    private let phoneNumberInfoView = MyPageTabItemView(title: "핸드폰번호")
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let changePasswordItem = MyPageTabItemView(title: "비밀번호 변경")
    
    private let removeAuthItem = MyPageTabItemView(title: "회원탈퇴")
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let 
}
