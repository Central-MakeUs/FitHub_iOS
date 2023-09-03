//
//  HomeViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {
    private let viewModel: HomeViewModel
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = true
    }
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "사용자님,\n오늘도 힘내서 운동해봐요!"
        $0.font = .pretendard(.titleLarge)
        $0.textColor = .textDefault
    }
    
    private let certificationButton = UIButton(type: .system).then {
        $0.semanticContentAttribute = .forceRightToLeft
        $0.setTitleColor(.textSub01, for: .normal)
        $0.setTitle("운동인증하러가기", for: .normal)
        $0.setImage(UIImage(named: "ic_arrow_back_ios")?.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
    }
    
    private let levelImageView = UIImageView().then {
        $0.image = UIImage(named: "DefaultProfile")
        $0.contentMode = .scaleAspectFit
    }
    
    private let certifyCardView = CertifyCardView()
    
    private let nearbyGymGuideLabel = UILabel().then {
        $0.text = "내 근처 운동시설 둘러보기"
        $0.textColor = .textDefault
        $0.font = .pretendard(.titleMedium)
    }
    
    private let certificationRankerLabel = UILabel().then {
        $0.text = "최고의 운동 인증러"
        $0.textColor = .textDefault
        $0.font = .pretendard(.titleMedium)
    }
    
    private let updateTimeLabel = UILabel().then {
        $0.font = .pretendard(.bodySmall01)
        $0.textColor = .iconSub
        $0.text = "2023.06.30 17:00 기준"
    }
    
    private let rankerTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.register(RankInfoCell.self, forCellReuseIdentifier: RankInfoCell.identifier)
        $0.backgroundColor = .clear
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(SportCell.self, forCellWithReuseIdentifier: SportCell.identifier)
    }
    
    let alertItem = UIBarButtonItem(image: UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal),
                               style: .plain, target: nil, action: nil)
    
    init(_ viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.gestureRecognizers = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.updateHomeInfo()
        self.viewModel.checkAlarm()
    }
    
    override func setupAttributes() {
        self.addNotificationCenter()
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "logo_basic")))
        
        
        let bookmark = UIBarButtonItem(image: UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal),
                                       style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [alertItem,bookmark]
        
        bookmark.rx.tap
            .bind(onNext: { [weak self] in
                let usecase = BookMarkUseCase(homeRepository: HomeRepository(homeService: HomeService(),
                                                                             authService: UserService()),
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
        let input = HomeViewModel.Input()
        
        let output = self.viewModel.transform(input: input)
        
        output.category
            .bind(to: self.collectionView.rx.items(cellIdentifier: SportCell.identifier, cellType: SportCell.self)) { index, item, cell in
                cell.configureCell(item: item, selectedItem: nil)
            }
            .disposed(by: disposeBag)
        
        viewModel.rankingList
            .bind(to: self.rankerTableView.rx.items(cellIdentifier: RankInfoCell.identifier, cellType: RankInfoCell.self)) { index, item, cell in
                cell.configureCell(item)
            }
            .disposed(by: disposeBag)
        
        viewModel.userInfo
            .withUnretained(self)
            .bind(onNext: { (homeVC,userInfo) in
                homeVC.setTitleContent(userInfo)
                homeVC.certifyCardView.configureInfo(userInfo)
            })
            .disposed(by: disposeBag)
        
        viewModel.updateDate
            .asDriver(onErrorJustReturn: "")
            .map { $0.replacingOccurrences(of: "-", with: ".") }
            .map { $0 + " 12:00 기준"}
            .drive(updateTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        certifyCardView.infoButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.showLevelInfoVC()
            })
            .disposed(by: disposeBag)
        
        rankerTableView.rx.modelSelected(BestRecorderDTO.self)
            .bind(onNext: { [weak self] model in
                guard let userIdString = KeychainManager.read("userId"),
                let userId = Int(userIdString) else { return }
                if userId == model.id {
                    self?.tabBarController?.selectedIndex = 3
                } else {
                    self?.showOtherUserProfile(userId: model.id)
                }
            })
            .disposed(by: disposeBag)
        
        certificationButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.tabBarController?.selectedIndex = 1
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(CategoryDTO.self)
            .map { $0.id }
            .bind(onNext: { [weak self] categoryId in
                NotificationCenter.default.post(name: .tapLookupWithCategory, object: categoryId)
                self?.tabBarController?.selectedIndex = 2
            })
            .disposed(by: disposeBag)
        
        viewModel.alarmCheck
            .bind(onNext: { [weak self] isRemain in
                let image = isRemain ? UIImage(named: "AlertRemain") : UIImage(named: "Alert")
                self?.alertItem.image = image?.withRenderingMode(.alwaysOriginal)
            })
            .disposed(by: disposeBag)
    }
    
    private func showOtherUserProfile(userId: Int) {
        let usecase = OtherProfileUseCase(communityRepo: CommunityRepository(UserService(),
                                                                             certificationService: CertificationService(), articleService: ArticleService()),
                                          mypageRepo: MyPageRepository(service: UserService()))
        let otherProfileVC = OtherProfileViewController(viewModel: OtherProfileViewModel(userId: userId,
                                                                                         usecase: usecase))
        self.navigationController?.pushViewController(otherProfileVC, animated: true)
    }
    
    private func showLevelInfoVC() {
        let levelInfoVC = LevelInfoViewController(viewModel: self.viewModel)
        self.navigationController?.pushViewController(levelInfoVC, animated: true)
    }

    private func setTitleContent(_ userInfo: HomeUserInfoDTO) {
        let text = "\(userInfo.gradeName) \(userInfo.userNickname)님,\n오늘도 힘내서 운동 해봐요!"
        self.titleLabel.text = text
        self.titleLabel.highlightGradeName(grade: userInfo.gradeName,
                                           highlightText: userInfo.gradeName)
        self.levelImageView.kf.setImage(with: URL(string: userInfo.gradeImageUrl))
    }
    
    override func addSubView() {
        self.view.addSubview(scrollView)
        
        [titleLabel, certificationButton, levelImageView,
         certifyCardView, nearbyGymGuideLabel, collectionView,
         certificationRankerLabel, updateTimeLabel, rankerTableView].forEach {
            self.scrollView.addSubview($0)
        }
    }
    
    override func layout() {
        self.scrollView.snp.makeConstraints {
            $0.trailing.top.bottom.leading.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(15)
        }
        
        self.certificationButton.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.levelImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(20)
            $0.width.height.equalTo(80)
        }
        
        self.certifyCardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.certificationButton.snp.bottom).offset(33)
            $0.height.equalTo(167)
        }
        
        self.nearbyGymGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(self.certifyCardView.snp.bottom).offset(60)
        }
        
        self.collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.nearbyGymGuideLabel.snp.bottom).offset(20)
            $0.height.equalTo(100)
        }
        
        self.certificationRankerLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(self.view.frame.width-40)
            $0.top.equalTo(self.collectionView.snp.bottom).offset(50)
        }
        
        self.updateTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.certificationRankerLabel.snp.bottom).offset(6)
        }

        self.rankerTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.updateTimeLabel.snp.bottom).offset(20)
            $0.height.equalTo(400)
            $0.bottom.equalToSuperview()
        }
    }
}

extension HomeViewController {
    private func addNotificationCenter() {
        NotificationCenter.default.rx.notification(.presentAlert)
            .subscribe(onNext: { [weak self] notification in
                guard let self else { return }
                let usecase = OAuthLoginUseCase(OAuthLoginRepository(UserService()))
                let authVC = UINavigationController(rootViewController: OAuthLoginViewController(
                    OAuthLoginViewModel(usecase)))
                self.changeRootViewController(authVC)
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumInteritemSpacing = 5
            $0.itemSize = .init(width: 74, height: 100)
            $0.sectionInsetReference = .fromContentInset
            $0.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        return layout
    }
}

