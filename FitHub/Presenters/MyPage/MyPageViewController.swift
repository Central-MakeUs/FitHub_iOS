//
//  MyPageViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class MyPageViewController: BaseViewController {
    private let viewModel: MyPageViewModel
    
    private let scrollView = UIScrollView()
    
    private let profileImageButton = UIButton().then {
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
        $0.font = .pretendard(.titleMedium)
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
    
    private let privacyInfoSetting = MyPageTabItemView(title: "개인 정보 설정")
    
    private let notiSetting = MyPageTabItemView(title: "알림 설정")
    
    private let registrationRequest = MyPageTabItemView(title: "학원 등록 요청")
                                            
    private let termsOfUse = MyPageTabItemView(title: "약관 및 정책")
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let versionInfo = MyPageTabItemView(title: "버전 정보").then {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        $0.configureLabelMode(text: version)
    }
    
    private let logoutItem = MyPageTabItemView(title: "로그아웃")
    
    let alertItem = UIButton().then {
        $0.setImage(UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        tapItemBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .bgDefault
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        viewModel.checkRemainAlarm()
    }
    
    override func setupAttributes() {
        super.setupAttributes()
        NotificationCenter.default.rx.notification(.tapChangeMainExercise)
            .bind(onNext: { [weak self] _ in
                self?.showChangeMainExerciseVC()
            })
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "logo_basic")))
        
        let bookmark = UIButton().then {
            $0.setImage(UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 16
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: alertItem),
                                                   spacer,
                                                   UIBarButtonItem(customView: bookmark)]
        
        bookmark.rx.tap
            .bind(onNext: { [weak self] in
                let usecase = BookMarkUseCase(homeRepository: HomeRepository(homeService: HomeService(),
                                                                             authService: UserService(),
                                                                             certificationService: CertificationService()),
                                              communityRepository: CommunityRepository(UserService(),
                                                                                       certificationService: CertificationService(), articleService: ArticleService()))
                let bookMarkVC = BookMarkViewController(viewModel: BookMarkViewModel(usecase: usecase))
                
                self?.navigationController?.pushViewController(bookMarkVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        alertItem.rx.tap
            .bind(onNext: { [weak self] in
                let usecase = AlertUseCase(alarmRepo: AlarmRepository(service: AlarmService()))
                let alertVC = AlertViewController(viewModel: AlertViewModel(usecase: usecase))
                self?.navigationController?.pushViewController(alertVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func setupBinding() {
        deleteProfileImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.deleteProfileImage()
            })
            .disposed(by: disposeBag)
        
        profileImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showPhotoAlbum()
            })
            .disposed(by: disposeBag)
        
        viewModel.profileImageChange
            .bind(onNext: { [weak self] result in
                guard let self else { return }
                if let result {
                    self.profileImageButton.kf.setImage(with: URL(string: result.changedImageUrl), for: .normal)
                } else {
                    self.profileImageButton.setImage(UIImage(named: "DefaultProfile"), for: .normal)
                    self.deleteProfileImageButton.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.myPageInfo
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                self.exerciseCardList.resetItem()
                self.exerciseCardList.setItems(items: result.myExerciseList)
                self.deleteProfileImageButton.isHidden = result.myInfo.isDefaultProfile
                self.profileImageButton.kf.setImage(with: URL(string: result.myInfo.profileUrl ?? "DefaultProfile"), for: .normal)
                self.nameLabel.text = result.myInfo.nickname
                self.sportLabel.text = result.myInfo.mainExerciseInfo.category
                let grade = "Lv.\(result.myInfo.mainExerciseInfo.level) \(result.myInfo.mainExerciseInfo.gradeName)"
                self.gradeLabel.text = grade
                self.gradeLabel.highlightGradeName(grade: result.myInfo.mainExerciseInfo.gradeName, highlightText: grade)
            })
            .disposed(by: disposeBag)
        
        viewModel.logoutHandler
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isSuccess in
                if isSuccess {
                    KeychainManager.delete(key: "accessToken")
                    KeychainManager.delete(key: "userId")
                    self?.notiAlert("로그아웃 되었습니다.")
                    NotificationCenter.default.post(name: .presentAlert, object: nil)
                } else {
                    self?.notiAlert("로그아웃 실패")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.alarmCheck
            .bind(onNext: { [weak self] isRemain in
                let image = isRemain ? UIImage(named: "AlertRemain") : UIImage(named: "Alert")
                self?.alertItem.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            })
            .disposed(by: disposeBag)
    }

    override func addSubView() {
        self.view.addSubview(scrollView)
        
        [profileImageButton, cameraImageView, deleteProfileImageButton, nameLabel, sportLabel, gradeLabel, exerciseCardList,
         myFeedItem, separatorLineView, privacyInfoSetting, notiSetting, registrationRequest, termsOfUse, dividerView, versionInfo, logoutItem].forEach {
            self.scrollView.addSubview($0)
        }
    }
    
    //MARK: - 화면 이동
    private func showPrivacyInfoVC() {
        let privacyInfoSettingVC = PrivacyInfoSettingViewController(viewModel: self.viewModel)
        self.navigationController?.pushViewController(privacyInfoSettingVC, animated: true)
    }
    
    private func showChangeMainExerciseVC() {
        let changeMainExerciseVC = MainExerciseChangeViewController(self.viewModel)
        self.navigationController?.pushViewController(changeMainExerciseVC, animated: true)
    }
    
    override func layout() {
        scrollView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.width.equalTo(self.view.frame.width)
        }
        
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
            $0.top.equalTo(exerciseCardList.snp.bottom).offset(26)
        }
        
        separatorLineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(myFeedItem.snp.bottom).offset(15)
        }
        
        privacyInfoSetting.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(separatorLineView.snp.bottom).offset(15)
        }
        
        notiSetting.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(privacyInfoSetting.snp.bottom).offset(10)
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
}

//MARK: - PHPicker Delegate
extension MyPageViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    private func showPhotoAlbum() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let photoPickerVC = PHPickerViewController(configuration: configuration)
        photoPickerVC.delegate = self
        self.present(photoPickerVC, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let item = results.first else { return }
        let itemProvider = item.itemProvider

        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] result, error in
                guard let image = result as? UIImage else { return }
                self?.viewModel.changeProfileImage(image: image)
            }
        }
    }
}

extension MyPageViewController {
    private func tapItemBinding() {
        logoutItem.rx.tapGesture()
            .asDriver()
            .skip(1)
            .drive(onNext: { [weak self] _ in
                self?.viewModel.logout()
            })
            .disposed(by: disposeBag)
        
        privacyInfoSetting.rx.tapGesture()
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.showPrivacyInfoVC()
            })
            .disposed(by: disposeBag)
        
        myFeedItem.rx.tapGesture()
            .asDriver()
            .skip(1)
            .drive(onNext: { [weak self] _ in
                self?.showMyFeedVC()
            })
            .disposed(by: disposeBag)
        
        termsOfUse.rx.tapGesture()
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.showTermOfUseVC()
            })
            .disposed(by: disposeBag)
        
        registrationRequest.rx.tapGesture()
            .asDriver()
            .drive(onNext: { [weak self] _ in
                let exceptionVC = ExceptionViewController(title: "아직 준비중이에요!",
                                                          subTitle: "핏허브에서 열심히 공사중이니 조금만 기다려주시면 감사하겠습니다!")
                self?.navigationController?.pushViewController(exceptionVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        notiSetting.rx.tapGesture()
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.showNotiSettingVC()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 화면 이동
extension MyPageViewController {
    private func showMyFeedVC() {
        let usecase = MyFeedUseCase(communityRepo: CommunityRepository(UserService(),
                                                                       certificationService: CertificationService(),
                                                                       articleService: ArticleService()),
                                    mypageRepo: MyPageRepository(service: UserService()),
                                    homeRepo: HomeRepository(homeService: HomeService(),
                                                             authService: UserService(),
                                                             certificationService: CertificationService()))
        let feedVC = MyFeedViewController(MyFeedViewModel(usecase))
        self.navigationController?.pushViewController(feedVC, animated: true)
    }
    
    private func showTermOfUseVC() {
        let usecase = TermUseCase(homeRepo: HomeRepository(homeService: HomeService(),
                                                           authService: UserService(),
                                                           certificationService: CertificationService()))
        let termOfUseVC = TermsOfUseViewController(viewModel: TermOfUseViewModel(usecase: usecase))
        self.navigationController?.pushViewController(termOfUseVC, animated: true)
    }
    
    private func showNotiSettingVC() {
        let usecase = NotiSettingUseCase(homeRepo: HomeRepository(homeService: HomeService(),
                                                                  authService: UserService(),
                                                                  certificationService: CertificationService()))
        let notiSettingVC = NotiSettingViewController(viewModel: NotiSettingViewModel(usecase: usecase))
        self.navigationController?.pushViewController(notiSettingVC, animated: true)
    }
}
