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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchPrivacyInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        self.title = "개인 정보 설정"
    }
    
    override func setupBinding() {
        viewModel.privacyInfo
            .bind(onNext: { [weak self] info in
                guard let self else { return }
                self.nameInfoView.configureLabelMode(text: info.name)
                self.emailInfoView.configureLabelMode(text: info.email ?? "미등록")
                self.phoneNumberInfoView.configureLabelMode(text: info.phoneNum ?? "미등록")
                if info.isSocial { self.responseSocialLayout() }
            })
            .disposed(by: disposeBag)
        
        removeAuthItem.rx.tapGesture()
            .skip(1)
            .bind(onNext: { [weak self] _ in
                self?.showQuitAlert()
            })
            .disposed(by: disposeBag)
        
        viewModel.quitHandler
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isSuccess in
                if isSuccess {
                    self?.showQuitCompleteAlert()
                } else {
                    self?.notiAlert("서버 오류: 회원탈퇴 실패 ")
                }
            })
            .disposed(by: disposeBag)
        
        changePasswordItem.rx.tapGesture()
            .asDriver()
            .skip(1)
            .drive(onNext: { [weak self] _ in
                self?.showChangePasswordVC()
            })
            .disposed(by: disposeBag)
    }
    
    private func showChangePasswordVC() {
        let usecase = ResetPWUseCase(mypageRepository: MyPageRepository(service: UserService()))
        let passwordConfirmVC = PasswordConfirmViewController(viewModel: ResetPWViewModel(usecase: usecase))
        
        self.navigationController?.pushViewController(passwordConfirmVC, animated: true)
    }
    
    private func showQuitCompleteAlert() {
        let alert = StandardAlertController(title: "회원 탈퇴 완료", message: "안전하게 탈퇴가 완료되었습니다.\n다음에 또 만나요!")
        let ok = StandardAlertAction(title: "확인", style: .basic) { [weak self] _ in
            KeychainManager.delete(key: "accessToken")
            KeychainManager.delete(key: "userId")
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(ok)
        
        self.present(alert, animated: false)
    }
    
    private func showQuitAlert() {
        let alert = StandardAlertController(title: "정말 핏허브를 탈퇴하시겠어요?", message: "지금까지의 운동 기록 및 레벨 성장이 사라져요!")
        let cancel = StandardAlertAction(title: "취소", style: .cancel)
        let quit = StandardAlertAction(title: "탈퇴", style: .basic) { [weak self] _ in
            self?.viewModel.quitAuth()
        }
        
        alert.addAction([cancel, quit])
        
        self.present(alert, animated: false)
    }
    
    private func responseSocialLayout() {
        changePasswordItem.snp.remakeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0)
        }
        changePasswordItem.isHidden = true
    }
    
    override func addSubView() {
        [nameInfoView, emailInfoView, phoneNumberInfoView, dividerView, changePasswordItem, removeAuthItem].forEach {
            self.view.addSubview($0)
        }
    }
    
    override func layout() {
        nameInfoView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(12)
            $0.horizontalEdges.equalToSuperview()
        }
        
        emailInfoView.snp.makeConstraints {
            $0.top.equalTo(nameInfoView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        phoneNumberInfoView.snp.makeConstraints {
            $0.top.equalTo(emailInfoView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberInfoView.snp.bottom).offset(15)
            $0.height.equalTo(10)
            $0.horizontalEdges.equalToSuperview()
        }

        changePasswordItem.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview()
        }

        removeAuthItem.snp.makeConstraints {
            $0.top.equalTo(changePasswordItem.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}
