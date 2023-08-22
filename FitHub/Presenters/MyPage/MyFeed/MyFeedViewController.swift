//
//  MyFeedViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/19.
//

import UIKit
import RxSwift
import RxCocoa

final class MyFeedViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: MyFeedViewModel
    
    private let certificationBackView = MyFeedDefaultView(title: "운동 인증 이력이 없습니다.",
                                                          subTitle: "오늘의 운동을 인증해보세요!",
                                                          buttonName: "인증 하러가기")
    
    private let fitSiteBackView = MyFeedDefaultView(title: "작성한 게시글이 없습니다.",
                                                    subTitle: "핏사이트에서 운동이야기를 나눠보세요",
                                                    buttonName: "글 쓰러가기")
    
    private let certificationSelectionAllToggleButton = AllCheckButton()
    
    private let certicationSelectionDeleteButton = UIButton(type: .system).then {
        $0.setTitle("선택삭제", for: .normal)
        $0.setTitleColor(.textSub01, for: .normal)
        $0.titleLabel?.font = .pretendard(.bodySmall02)
    }
    
    private let fitSiteSelectionAllTogleButton = AllCheckButton()
    
    private let fitSiteSelectionDeleteButton = UIButton(type: .system).then {
        $0.setTitle("선택삭제", for: .normal)
        $0.setTitleColor(.textSub01, for: .normal)
        $0.titleLabel?.font = .pretendard(.bodySmall02)
    }
    
    private let contentView = UIView()
    
    private let indicatorUnderLineView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .iconDefault
    }
    
    private lazy var topTabBarCollectionView = UICollectionView(frame: .zero,
                                                           collectionViewLayout: createTopTabBar()).then {
        $0.register(TopTabBarItemCell.self, forCellWithReuseIdentifier: TopTabBarItemCell.identifier)
        $0.backgroundColor = .clear
    }
    
    private lazy var categoryCollectionView = UICollectionView(frame: .zero,
                                                               collectionViewLayout: self.createLayout()).then {
        $0.backgroundColor = .clear
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
    }
    
    private let feedScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
    }

    private lazy var certificationCollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: createCertificationLayout()).then {
        $0.showsVerticalScrollIndicator = false
        $0.register(CertificationCell.self, forCellWithReuseIdentifier: CertificationCell.identifier)
        $0.backgroundColor = .bgDefault
    }
    
    private let fitSiteTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.register(MyFitSiteCell.self, forCellReuseIdentifier: MyFitSiteCell.identifier)
        $0.backgroundColor = .bgDefault
    }
    
    //MARK: - Init
    init(_ viewModel: MyFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.gestureRecognizers = nil
        self.view.backgroundColor = .bgDefault
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTabBarBinding()
        pagingBinding()
        setDefaultView()
        
        self.view.gestureRecognizers = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.viewModel.isFirstViewDidAppear {
            self.viewModel.communityType.onNext(.certification)
            self.viewModel.isFirstViewDidAppear = false
        }
    }
    
    //MARK: - ConfigureNavigation
    override func configureNavigation() {
        super.configureNavigation()
        let noti = UIBarButtonItem(image: UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal),
                                   style: .plain, target: nil, action: nil)
        let bookmark = UIBarButtonItem(image: UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal),
                                       style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [noti,bookmark]

        
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
        
        self.title = "내 글 관리"
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        viewModel.category
            .bind(to: self.categoryCollectionView.rx
                .items(cellIdentifier: CategoryCell.identifier,
                       cellType: CategoryCell.self)) { [weak self] index, name, cell in
                guard let self else { return }
                if let selectedItems = categoryCollectionView.indexPathsForSelectedItems,
                   selectedItems.isEmpty {
                    categoryCollectionView.selectItem(at: IndexPath(item: 0, section: 0),
                                                      animated: false,
                                                      scrollPosition: .centeredVertically)
                }
                cell.configureLabel(name.name)
            }
                       .disposed(by: disposeBag)
        
        viewModel.certificationFeedList
            .bind(to: self.certificationCollectionView.rx
                .items(cellIdentifier: CertificationCell.identifier,
                       cellType: CertificationCell.self)) { [weak self] index, item, cell in
                guard let self else { return }
                let isSelected = self.viewModel.selectedRecoridIdList.value.contains(item.recordId)
                cell.delegate = self
                cell.configureMyFeeCell(item, isSelected: isSelected)
            }
                       .disposed(by: disposeBag)
        
        viewModel.fitSiteFeedList
            .bind(to: self.fitSiteTableView.rx.items(cellIdentifier: MyFitSiteCell.identifier, cellType: MyFitSiteCell.self)) { [weak self] index, item, cell in
                guard let self else { return }
                cell.delegate = self
                let isSelected = self.viewModel.selectedArticleidIdList.value.contains(item.articleId)
                cell.configureCell(item: item, isSelected: isSelected)
            }
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(CategoryDTO.self)
            .map { $0.id }
            .bind(to: viewModel.selectedCategory)
            .disposed(by: disposeBag)
        
        viewModel.feedType
            .bind(to: self.topTabBarCollectionView.rx.items(cellIdentifier: TopTabBarItemCell.identifier, cellType: TopTabBarItemCell.self)) { [weak self] index, item, cell in
                cell.configureCell(text: item)
            }
            .disposed(by: disposeBag)
        
        self.certificationCollectionView.rx.modelSelected(CertificationDTO.self)
            .map { $0.recordId }
            .bind(onNext: { [weak self] recordId in
                self?.pushCertificationDetail(recordId: recordId)
            })
            .disposed(by: disposeBag)
        
        self.fitSiteTableView.rx.modelSelected(ArticleDTO.self)
            .map { $0.articleId }
            .bind(onNext: { [weak self] articleId in
                self?.pushFitSiteDetail(articleId: articleId)
            })
            .disposed(by: disposeBag)
        
        certificationSelectionAllToggleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.toggleCertificationAllSelection()
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedRecoridIdList
            .subscribe(onNext: { [weak self] _ in
                self?.certificationCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.certificationAllButtonCheck
            .bind(to: certificationSelectionAllToggleButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        certicationSelectionDeleteButton.rx.tap
            .subscribe(onNext: {[weak self] in
                self?.viewModel.deleteCertifications()
            })
            .disposed(by: disposeBag)
        
        fitSiteSelectionAllTogleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.toggleFitSiteAllSelection()
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedArticleidIdList
            .subscribe(onNext: { [weak self] _ in
                self?.fitSiteTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.fitSiteAllButtonCheck
            .bind(to: fitSiteSelectionAllTogleButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        fitSiteSelectionDeleteButton.rx.tap
            .subscribe(onNext: {[weak self] in
                self?.viewModel.deleteFitSites()
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - 화면이동
    private func showSearchVC() {
        let usecase = SearchUseCase(searchRepository: SearchRepository(service: SearchService()))
        let searchVC = SearchViewController(viewModel: SearchViewModel(usecase: usecase))
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    private func pushCreateCertificationVC() {
        let usecase = CreateCertificationUseCase(repository: CreateCertificationRepository(certificationService: CertificationService(),
                                                                                       authService: UserService()))
        let createCertificationVC = CreateCertificationViewController(CreateCertificationViewModel(usecase: usecase))
        self.navigationController?.pushViewController(createCertificationVC, animated: true)
    }
    
    private func pushCreateFitSiteVC() {
        let usecase = CreateFitSiteUseCase(repository: CreateFitSiteRepository(authService: UserService(),
                                                                               articleService: ArticleService()))
        let createFitSiteVC = CreateFitSiteViewController(CreateFitSiteViewModel(usecase: usecase))
        self.navigationController?.pushViewController(createFitSiteVC, animated: true)
    }
    
    private func pushCertificationDetail(recordId: Int) {
        let usecase = CertifiactionDetailUseCase(certificationRepository: CertificationRepository(service: CertificationService()),
                                                 commentRepository: CommentRepository(service: CommentService()),
                                                 communityRepostiroy: CommunityRepository(UserService(),
                                                                                          certificationService: CertificationService(),
                                                                                          articleService: ArticleService()))
        let certificationDetailVC = CertificationDetailViewController(viewModel: CertificationDetailViewModel(usecase: usecase,
                                                                                                              recordId: recordId))
        
        self.navigationController?.pushViewController(certificationDetailVC, animated: true)
    }
    
    private func pushFitSiteDetail(articleId: Int) {
        let usecase = FitSiteDetailUseCase(commentRepository: CommentRepository(service: CommentService()),
                                         fitSiteRepository: FitSiteRepository(service: ArticleService()),
                                           communityRepository: CommunityRepository(UserService(),
                                                                                    certificationService: CertificationService(),
                                                                                    articleService: ArticleService()))
        let fitSiteDetailVC = FitSiteDetailViewController(viewModel: FitSiteDetailViewModel(usecase: usecase,
                                                                                            articleId: articleId))
        
        self.navigationController?.pushViewController(fitSiteDetailVC, animated: true)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(topTabBarCollectionView)
        self.view.addSubview(indicatorUnderLineView)
        self.view.addSubview(indicatorView)
        self.view.addSubview(feedScrollView)
        self.view.addSubview(categoryCollectionView)
        
        self.feedScrollView.addSubview(contentView)
        self.feedScrollView.addSubview(certificationSelectionAllToggleButton)
        self.feedScrollView.addSubview(certicationSelectionDeleteButton)
        self.feedScrollView.addSubview(fitSiteSelectionAllTogleButton)
        self.feedScrollView.addSubview(fitSiteSelectionDeleteButton)
        self.feedScrollView.addSubview(fitSiteTableView)
        self.feedScrollView.addSubview(certificationCollectionView)
    }
    
    //MARK: - layout
    override func layout() {
        self.topTabBarCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(6)
            $0.height.equalTo(50)
        }
        
        self.categoryCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(self.topTabBarCollectionView.snp.bottom).offset(15)
            $0.height.equalTo(32)
        }
        
        feedScrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(20)
        }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(self.view.frame.width*2)
            $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        certificationSelectionAllToggleButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(self.certificationCollectionView)
        }
        
        certicationSelectionDeleteButton.snp.makeConstraints {
            $0.centerY.equalTo(certificationSelectionAllToggleButton)
            $0.trailing.equalTo(self.certificationCollectionView)
        }
        
        certificationCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.certificationSelectionAllToggleButton.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 40)
            $0.height.equalTo(contentView.snp.height)
        }
        
        fitSiteSelectionAllTogleButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(self.fitSiteTableView)
        }
        
        fitSiteSelectionDeleteButton.snp.makeConstraints {
            $0.centerY.equalTo(fitSiteSelectionAllTogleButton)
            $0.trailing.equalTo(self.fitSiteTableView)
        }
        
        fitSiteTableView.snp.makeConstraints {
            $0.leading.equalTo(self.certificationCollectionView.snp.trailing).offset(40)
            $0.top.equalTo(self.fitSiteSelectionAllTogleButton.snp.bottom).offset(15)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }
        
        indicatorUnderLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(topTabBarCollectionView.snp.bottom)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.centerY.equalTo(indicatorUnderLineView.snp.centerY)
            make.centerX.equalToSuperview()
            make.width.equalTo(15)
            make.height.equalTo(3)
        }
    }
}

// MARK: - CollectionLayout
extension MyFeedViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(1),
                                              heightDimension: .absolute(32))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(3),
                                               heightDimension: .fractionalHeight(1))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createCertificationLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                              heightDimension: .fractionalWidth(0.67))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.interGroupSpacing = 5
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createTopTabBar() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5),
                                                            heightDimension: .absolute(50)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .absolute(50)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Paging
extension MyFeedViewController {
    private func pagingBinding() {
        certificationCollectionView.rx.didScroll
            .map { [weak self] Void -> (offsetY: CGFloat, contentHeight: CGFloat, frameHeight: CGFloat) in
                guard let self else { return (0,0,0) }
                return (self.certificationCollectionView.contentOffset.y,
                        self.certificationCollectionView.contentSize.height,
                        self.certificationCollectionView.frame.height)
            }
            .bind(to: viewModel.certificationDidScroll)
            .disposed(by: disposeBag)
        
        fitSiteTableView.rx.didScroll
            .map { [weak self] Void -> (offsetY: CGFloat, contentHeight: CGFloat, frameHeight: CGFloat) in
                guard let self else { return (0,0,0) }
                return (self.fitSiteTableView.contentOffset.y,
                        self.fitSiteTableView.contentSize.height,
                        self.fitSiteTableView.frame.height)
            }
            .bind(to: viewModel.fitSiteDidScroll)
            .disposed(by: disposeBag)
    }
}

// MARK: - TopTabBar
extension MyFeedViewController {
    func moveIndicatorbar(targetIndex: Int) {
        let indexPath = IndexPath(item: targetIndex, section: 0)
        topTabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        guard let cell = topTabBarCollectionView.cellForItem(at: indexPath) as? TopTabBarItemCell else { return }
        
        indicatorView.snp.remakeConstraints {
            $0.centerX.equalTo(cell)
            $0.width.equalTo(cell.getTitleFrameWidth())
            $0.height.equalTo(3)
            $0.centerY.equalTo(indicatorUnderLineView)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func topTabBarBinding() {
        viewModel.communityType
            .bind(onNext: { [weak self] type in
                self?.moveIndicatorbar(targetIndex: type.rawValue)
            })
            .disposed(by: disposeBag)
        
        topTabBarCollectionView.rx.itemSelected
            .map { $0.item }
            .subscribe(onNext: { [weak self] idx in
                guard let self else { return }
                if idx == 0 {
                    self.feedScrollView
                        .contentOffset = .init(x: 0, y: 0)
                } else {
                    self.feedScrollView
                        .contentOffset = .init(x: self.view.frame.width, y: 0)
                }
                self.viewModel.communityType.onNext(.init(rawValue: idx) ?? .certification)
            })
            .disposed(by: disposeBag)
        
        feedScrollView.rx.didScroll
            .bind(onNext: { [weak self] in
                guard let self else { return }
                let targetIndex = Int(feedScrollView.contentOffset.x/self.view.frame.width)
                let indexPath = IndexPath(item: targetIndex, section: 0)
                guard let cell = topTabBarCollectionView.cellForItem(at: indexPath) as? TopTabBarItemCell else { return }
                
                indicatorView.snp.remakeConstraints {
                    $0.centerX.equalTo(self.view.frame.width/4 + self.feedScrollView.contentOffset.x/2)
                    $0.width.equalTo(cell.getTitleFrameWidth())
                    $0.height.equalTo(3)
                    $0.centerY.equalTo(self.indicatorUnderLineView)
                }
                
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                
                if feedScrollView.contentOffset.x == self.view.frame.width {
                    self.viewModel.communityType.onNext(.fitSite)
                } else if feedScrollView.contentOffset.x == 0 {
                    self.viewModel.communityType.onNext(.certification)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - CellDelegate
extension MyFeedViewController: CertificationCellDelegate, MyFitSiteCellDelegate {
    func toggleSelectedFitSite(articleId: Int) {
        var idList = viewModel.selectedArticleidIdList.value
        if idList.contains(articleId) {
            idList.remove(articleId)
        } else {
            idList.insert(articleId)
        }
        viewModel.selectedArticleidIdList.accept(idList)
    }
    
    func toggleSelected(recordId: Int) {
        var idList = viewModel.selectedRecoridIdList.value
        if idList.contains(recordId) {
            idList.remove(recordId)
        } else {
            idList.insert(recordId)
        }
        viewModel.selectedRecoridIdList.accept(idList)
    }
}

// MARK: - DefaultView
extension MyFeedViewController {
    private func setDefaultView() {
        certificationCollectionView.backgroundView = certificationBackView
        fitSiteTableView.backgroundView = fitSiteBackView
        
        viewModel.fitSiteFeedList
            .map { !$0.isEmpty }
            .bind(to: fitSiteBackView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.certificationFeedList
            .map { !$0.isEmpty }
            .bind(to: certificationBackView.rx.isHidden)
            .disposed(by: disposeBag)
        
        certificationBackView.moveButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.tabBarController?.selectedIndex = 1
                self?.navigationController?.popToRootViewController(animated: false)
            })
            .disposed(by: disposeBag)
        
        fitSiteBackView.moveButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.tabBarController?.selectedIndex = 1
                self?.navigationController?.popToRootViewController(animated: false)
            })
            .disposed(by: disposeBag)
    }
}
