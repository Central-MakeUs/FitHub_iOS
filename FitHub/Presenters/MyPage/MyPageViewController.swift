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
    
    private let scrollView = UIScrollView()
    
    private let profileImageButton = UIButton(type: .system).then {
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub01
        $0.layer.cornerRadius = 40
        $0.setImage(UIImage(named: "DefaultProfile")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private let cameraImageView = UIImageView().then {
        $0.image = UIImage(named: "ProfileCamera")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let deleteProfileImageButton = UIButton(type: .system).then {
        $0.isHidden = true
        $0.titleLabel?.font = .pretendard(.labelSmall)
        $0.setTitleColor(.textSub02, for: .normal)
        $0.setTitle("프로필 사진 삭제", for: .normal)
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "사용자명"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyMedium02)
    }
    
    private let sportLabel = PaddingLabel(padding: .init(top: 2, left: 4, bottom: 2, right: 4)).then {
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub02
        $0.layer.cornerRadius = 2
        $0.text = "운동명"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
    }
    
    private let gradeLabel = PaddingLabel(padding: .init(top: 2, left: 4, bottom: 2, right: 4)).then {
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub02
        $0.layer.cornerRadius = 2
        $0.text = "Lv100.코딩지옥"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
    }
    
    private let exerciseCardList = CardPagingControlView().then {
        $0.layer.cornerRadius = 5
        $0.backgroundColor = .bgSub01
    }
    
    private let myFeedItem = MyPageTabItemView(title: "내 글 관리")
    
    private let separatorLineView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let privacySetting = MyPageTabItemView(title: "개인 정보 설정")
    
    private let notiSetting = MyPageTabItemView(title: "알림 설정")
    
    private let registrationRequest = MyPageTabItemView(title: "학원 등록 요청")
                                            
    private let termsOfUse = MyPageTabItemView(title: "약관 및 정책")
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let versionInfo = MyPageTabItemView(title: "버전 정보").then {
        $0.subLabel.isHidden = true
    }
    
    private let logoutItem = MyPageTabItemView(title: "로그아웃")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .bgDefault
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "logo_basic")))
        
        let noti = UIBarButtonItem(image: UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal),
                                   style: .plain, target: nil, action: nil)
        let bookmark = UIBarButtonItem(image: UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal),
                                       style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [noti,bookmark]
        
        bookmark.rx.tap
            .bind(onNext: { [weak self] in
                let usecase = BookMarkUseCase(homeRepository: HomeRepository(homeService: HomeService(),
                                                                             authService: AuthService()),
                                              communityRepository: CommunityRepository(AuthService(),
                                                                                       certificationService: CertificationService(), articleService: ArticleService()))
                let bookMarkVC = BookMarkViewController(viewModel: BookMarkViewModel(usecase: usecase))
                
                self?.navigationController?.pushViewController(bookMarkVC, animated: true)
            })
            .disposed(by: disposeBag)
    }

    override func addSubView() {
        self.view.addSubview(scrollView)
        
        [logoutButton, profileImageButton, cameraImageView, deleteProfileImageButton, nameLabel, sportLabel, gradeLabel, exerciseCardList,
         myFeedItem, separatorLineView, privacySetting, notiSetting, registrationRequest, termsOfUse, dividerView, versionInfo, logoutItem].forEach {
            self.scrollView.addSubview($0)
        }
        
    }
    
    override func layout() {
        scrollView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.width.equalTo(self.view.frame.width)
        }
        
//        logoutButton.snp.makeConstraints {
//            $0.center.equalToSuperview()
//        }
        
        profileImageButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(15)
            $0.width.height.equalTo(80)
        }
        
        cameraImageView.snp.makeConstraints {
            $0.trailing.bottom.equalTo(profileImageButton)
            $0.width.height.equalTo(28)
        }
        
        deleteProfileImageButton.snp.makeConstraints {
            $0.centerX.equalTo(profileImageButton)
            $0.top.equalTo(profileImageButton.snp.bottom).offset(10)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageButton.snp.trailing).offset(30)
            $0.bottom.equalTo(profileImageButton.snp.centerY)
        }
        
        sportLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        gradeLabel.snp.makeConstraints {
            $0.leading.equalTo(sportLabel.snp.trailing).offset(3)
            $0.centerY.equalTo(sportLabel)
        }
        
        exerciseCardList.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(self.view.frame.width-40)
            $0.top.equalTo(profileImageButton.snp.bottom).offset(46)
            $0.height.equalTo(122)
        }
        
        myFeedItem.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(exerciseCardList.snp.bottom).offset(15)
        }
        
        separatorLineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(myFeedItem.snp.bottom).offset(15)
        }
        
        privacySetting.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(separatorLineView.snp.bottom).offset(15)
        }
        
        notiSetting.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(privacySetting.snp.bottom).offset(10)
        }
        
        registrationRequest.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(notiSetting.snp.bottom).offset(10)
        }
        
        termsOfUse.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(registrationRequest.snp.bottom).offset(10)
        }
        
        dividerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(10)
            $0.top.equalTo(termsOfUse.snp.bottom).offset(15)
        }
        
        versionInfo.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(dividerView.snp.bottom).offset(15)
        }
        
        logoutItem.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(versionInfo.snp.bottom).offset(15)
            $0.bottom.equalToSuperview().offset(-60)
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
