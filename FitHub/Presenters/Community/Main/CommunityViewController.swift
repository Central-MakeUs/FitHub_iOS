//
//  CommunityViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit
import RxSwift
import RxCocoa

final class CommunityViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: CommunityViewModel
    
    private let searchBar = FitHubSearchBar(frame: .init(x: 0, y: 0, width: 100, height: 44)).then {
        $0.searchTextField.isEnabled = false
    }
    private let certificationSortView = SortSwitchView()
    private let fitSiteSortView = SortSwitchView()
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
        $0.register(FitSiteCell.self, forCellReuseIdentifier: FitSiteCell.identifier)
        $0.backgroundColor = .bgDefault
    }
    
    private let floatingButton = UIButton(type: .system).then {
        $0.backgroundColor = .primary
        $0.layer.cornerRadius = 28
        $0.setImage(UIImage(named: "Plus_Floating")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private let createActionSheet = CreateActionSheet().then {
        $0.isHidden = true
    }
    
    private let actionSheetBackView = UIView().then {
        $0.backgroundColor = .bgDefault.withAlphaComponent(0.5)
        $0.isHidden = true
    }
    
    //MARK: - Init
    init(_ viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.gestureRecognizers = nil
        self.view.backgroundColor = .bgDefault
        setCertificationDefaultView()
        setFitSiteDefaultView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTabBarBinding()
        pagingBinding()
        
        self.view.gestureRecognizers = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.viewModel.isFirstViewDidAppear {
            self.viewModel.communityType.onNext(.certification)
            self.viewModel.isFirstViewDidAppear = false
        }
        
        if let selectedItems = categoryCollectionView.indexPathsForSelectedItems,
           selectedItems.isEmpty {
            categoryCollectionView.selectItem(at: IndexPath(item: 0, section: 0),
                                              animated: false,
                                              scrollPosition: .centeredVertically)
        }
    }
    
    //MARK: - ConfigureUI
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    //MARK: - ConfigureNavigation
    override func configureNavigation() {
        super.configureNavigation()
        let noti = UIBarButtonItem(image: UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal),
                                   style: .plain, target: nil, action: nil)
        let bookmark = UIBarButtonItem(image: UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal),
                                       style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [noti,bookmark]
        
        self.navigationItem.titleView = searchBar
        
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
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        viewModel.category
            .bind(to: self.categoryCollectionView.rx
                .items(cellIdentifier: CategoryCell.identifier,
                       cellType: CategoryCell.self)) { index, name, cell in
                cell.configureLabel(name.name)
            }
                       .disposed(by: disposeBag)
        
        viewModel.certificationFeedList
            .bind(to: self.certificationCollectionView.rx
                .items(cellIdentifier: CertificationCell.identifier,
                       cellType: CertificationCell.self)) { index, item, cell in
                cell.configureCell(item)
            }
                       .disposed(by: disposeBag)
        
        viewModel.fitSiteFeedList
            .bind(to: self.fitSiteTableView.rx.items(cellIdentifier: FitSiteCell.identifier, cellType: FitSiteCell.self)) { index, item, cell in
                cell.configureCell(item: item)
            }
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(CategoryDTO.self)
            .map { $0.id }
            .bind(to: viewModel.selectedCategory)
            .disposed(by: disposeBag)
        
        viewModel.feedType
            .bind(to: self.topTabBarCollectionView.rx.items(cellIdentifier: TopTabBarItemCell.identifier, cellType: TopTabBarItemCell.self)) { index, item, cell in
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
        
        self.floatingButton.rx.tap
            .map { !self.actionSheetBackView.isHidden }
            .subscribe(onNext: { [weak self] isHidden in
                self?.actionSheetBackView.isHidden = isHidden
                self?.createActionSheet.isHidden = isHidden
                let buttonImgName = isHidden ? "Plus_Floating" : "Minus_Floating"
                self?.floatingButton.setImage(UIImage(named: buttonImgName)?.withRenderingMode(.alwaysOriginal),
                                              for: .normal)
            })
            .disposed(by: disposeBag)
        
        self.certificationSortView.type
            .bind(to: self.viewModel.certificationSortingType)
            .disposed(by: disposeBag)
        
        self.fitSiteSortView.type
            .bind(to: self.viewModel.fitStieSortingType)
            .disposed(by: disposeBag)
        
        self.createActionSheet.certificationButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.pushCreateCertificationVC()
                self?.closeCreateActionSheet()
            })
            .disposed(by: disposeBag)
        
        self.createActionSheet.createFeedButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.pushCreateFitSiteVC()
                self?.closeCreateActionSheet()
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.tapGesture()
            .bind(onNext: { [weak self] _ in
                self?.showSearchVC()
            })
            .disposed(by: disposeBag)
    }
    
    private func closeCreateActionSheet() {
        self.actionSheetBackView.isHidden = true
        self.createActionSheet.isHidden = true
        self.floatingButton.setImage(UIImage(named: "Plus_Floating")?.withRenderingMode(.alwaysOriginal),
                                      for: .normal)
    }
    
    //MARK: - 화면이동
    private func showSearchVC() {
        let usecase = SearchUseCase(searchRepository: SearchRepository(service: SearchService()))
        let searchVC = SearchViewController(viewModel: SearchViewModel(usecase: usecase))
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    private func pushCreateCertificationVC() {
        let usecase = EditCertificationUseCase(repository: EditCertificationRepository(certificationService: CertificationService(),
                                                                                       authService: UserService()))
        let editCertificationVC = EditCertificationViewController(EditCertificationViewModel(usecase: usecase))
        self.navigationController?.pushViewController(editCertificationVC, animated: true)
    }
    
    private func pushCreateFitSiteVC() {
        let usecase = CreateFitSiteUseCase(repository: CreateFitSiteRepository(authService: UserService(),
                                                                               articleService: ArticleService()))
        let editFitSiteVC = EditFitSiteViewController(EditFitSiteViewModel(usecase: usecase))
        self.navigationController?.pushViewController(editFitSiteVC, animated: true)
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
        self.view.addSubview(actionSheetBackView)
        self.view.addSubview(floatingButton)
        self.view.addSubview(createActionSheet)
        
        self.feedScrollView.addSubview(contentView)
        self.feedScrollView.addSubview(certificationSortView)
        self.feedScrollView.addSubview(fitSiteSortView)
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

        self.certificationSortView.snp.makeConstraints {
            $0.trailing.equalTo(self.certificationCollectionView.snp.trailing)
            $0.top.equalToSuperview().offset(4)
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
        
        certificationCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.certificationSortView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 40)
            $0.height.equalTo(contentView.snp.height)
        }
        
        fitSiteSortView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.trailing.equalTo(self.fitSiteTableView.snp.trailing)
        }
        
        fitSiteTableView.snp.makeConstraints {
            $0.leading.equalTo(self.certificationCollectionView.snp.trailing).offset(40)
            $0.top.equalTo(self.fitSiteSortView.snp.bottom).offset(15)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 40)
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
        
        self.floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-30)
            $0.width.height.equalTo(56)
        }
        
        self.actionSheetBackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.createActionSheet.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(self.floatingButton.snp.top).offset(-10)
        }
    }
}

extension CommunityViewController {
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
extension CommunityViewController {
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
extension CommunityViewController {
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
extension CommunityViewController {
    private func setFitSiteDefaultView() {
        let defaultView = UIView()
        let guideLabel = UILabel().then {
            $0.text = "아직 작성한 글이 없습니다."
            $0.textColor = .textDefault
            $0.font = .pretendard(.bodyLarge02)
        }
        
        defaultView.addSubview(guideLabel)
        guideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        fitSiteTableView.backgroundView = defaultView
        
        viewModel.fitSiteFeedList
            .map { !$0.isEmpty }
            .bind(to: defaultView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setCertificationDefaultView() {
        let defaultView = UIView()
        let guideLabel = UILabel().then {
            $0.text = "아직 작성한 글이 없습니다."
            $0.textColor = .textDefault
            $0.font = .pretendard(.bodyLarge02)
        }
        
        defaultView.addSubview(guideLabel)
        guideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        certificationCollectionView.backgroundView = defaultView
        
        viewModel.certificationFeedList
            .map { !$0.isEmpty }
            .bind(to: defaultView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

