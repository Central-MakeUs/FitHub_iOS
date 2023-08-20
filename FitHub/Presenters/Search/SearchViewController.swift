//
//  SearchViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class SearchViewController: BaseViewController {
    private let viewModel: SearchViewModel
    
    private let searchBar = CustomSearchBar()
    
    private let fitSiteBackGroundView = EmptyResultView().then {
        $0.isHidden = true
    }
    
    private let certificationBackGroundView = EmptyResultView().then {
        $0.isHidden = true
    }
    
    private let recommendView = RecommendView()
    
    private let feedScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
    }
    
    private let indicatorUnderLineView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .iconDefault
    }
    
    private let certificationSortView = SortSwitchView()
    private let fitSiteSortView = SortSwitchView()
    private let contentView = UIView()
    
    private lazy var totalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.backgroundColor = .bgDefault
        $0.register(SearchTotalHeaderView.self, forSupplementaryViewOfKind: SearchTotalHeaderView.certification, withReuseIdentifier: SearchTotalHeaderView.identifier)
        $0.register(SearchTotalHeaderView.self, forSupplementaryViewOfKind: SearchTotalHeaderView.fitSite, withReuseIdentifier: SearchTotalHeaderView.identifier)
        $0.register(CertificationCell.self, forCellWithReuseIdentifier: CertificationCell.identifier)
        $0.register(FitSiteCollectionCell.self, forCellWithReuseIdentifier: FitSiteCollectionCell.identifier)
    }
    
    private let tempView = UIView().then {
        $0.backgroundColor = .red
    }
    
    private lazy var topTabBarCollectionView = UICollectionView(frame: .zero,
                                                                collectionViewLayout: createTopTabBar()).then {
        $0.register(TopTabBarItemCell.self, forCellWithReuseIdentifier: TopTabBarItemCell.identifier)
        $0.backgroundColor = .clear
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
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.gestureRecognizers = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleResultHidden(isHidden: true)
        topTabBarBinding()
        pagingBinding()
        emptyResultBinding()
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        self.navigationItem.titleView = searchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.isFirstViewDidAppear {
            viewModel.communityType.onNext(.total)
            viewModel.isFirstViewDidAppear = false
        }
    }
    
    override func setupBinding() {
        viewModel.keywords
            .bind(to: recommendView.keywordCollectionView.rx.items(cellIdentifier: CategoryCell.identifier, cellType: CategoryCell.self)) { index, item, cell in
                cell.isUseSelected = false
                cell.configureLabel(item)
            }
            .disposed(by: disposeBag)
        
        viewModel.topTabBarItems
            .bind(to: topTabBarCollectionView.rx.items(cellIdentifier: TopTabBarItemCell.identifier, cellType: TopTabBarItemCell.self)) { index, item, cell in
                cell.configureCell(text: item)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .compactMap { self.searchBar.text }
            .bind(onNext: { [weak self] text in
                self?.searchBar.resignFirstResponder()
                self?.viewModel.searchText.accept(text)
                self?.recommendView.isHidden = true
                self?.toggleResultHidden(isHidden: false)
            })
            .disposed(by: disposeBag)
        
        recommendView.keywordCollectionView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] text in
                self?.searchBar.text = text
                self?.searchBar.resignFirstResponder()
                self?.viewModel.searchText.accept(text)
                self?.recommendView.isHidden = true
                self?.toggleResultHidden(isHidden: false)
            })
            .disposed(by: disposeBag)
        
        self.certificationSortView.type
            .bind(to: self.viewModel.certificationSortingType)
            .disposed(by: disposeBag)
        
        self.fitSiteSortView.type
            .bind(to: self.viewModel.fitStieSortingType)
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
        
        let todalDataSource = createDataSoruce()
        
        viewModel.totalDataSource
            .bind(to: totalCollectionView.rx.items(dataSource: todalDataSource))
            .disposed(by: disposeBag)
        
        totalCollectionView.rx.modelSelected(SearchTotalSectionModel.Item.self)
            .subscribe(onNext: { [weak self] result in
                print(result)
                switch result {
                case .certification(record: let record):
                    self?.pushCertificationDetail(recordId: record.recordId)
                case .fitSite(article: let article):
                    self?.pushFitSiteDetail(articleId: article.articleId)
                }
            })
            .disposed(by: disposeBag)
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
    
    private func toggleResultHidden(isHidden: Bool) {
        feedScrollView.isHidden = isHidden
        indicatorView.isHidden = isHidden
        indicatorUnderLineView.isHidden = isHidden
        topTabBarCollectionView.isHidden = isHidden
    }
    
    override func addSubView() {
        [recommendView, topTabBarCollectionView, indicatorUnderLineView, indicatorView, feedScrollView].forEach {
            self.view.addSubview($0)
        }
        
        [contentView,totalCollectionView,fitSiteSortView,certificationSortView,fitSiteTableView,certificationCollectionView].forEach {
            feedScrollView.addSubview($0)
        }
    }
    
    override func layout() {
        recommendView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        topTabBarCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(6)
            $0.height.equalTo(50)
        }
        
        indicatorUnderLineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(topTabBarCollectionView.snp.bottom)
        }
        
        indicatorView.snp.makeConstraints {
            $0.centerY.equalTo(indicatorUnderLineView.snp.centerY)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(15)
            $0.height.equalTo(3)
        }
        
        feedScrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.indicatorUnderLineView.snp.bottom).offset(20)
        }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(self.view.frame.width*3)
            $0.top.equalTo(self.indicatorUnderLineView.snp.bottom).offset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        certificationSortView.snp.makeConstraints {
            $0.trailing.equalTo(self.certificationCollectionView.snp.trailing)
            $0.top.equalToSuperview().offset(4)
        }
        
        totalCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 40)
            $0.height.equalTo(contentView.snp.height)
        }
        
        certificationCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.certificationSortView.snp.bottom).offset(15)
            $0.leading.equalTo(totalCollectionView.snp.trailing).offset(40)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 40)
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
    }
}

// MARK: - Paging
extension SearchViewController {
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

extension SearchViewController {
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
        
        if targetIndex == 0 {
            self.feedScrollView
                .contentOffset = .init(x: 0, y: 0)
        } else if targetIndex == 1 {
            self.feedScrollView
                .contentOffset = .init(x: self.view.frame.width, y: 0)
        } else {
            self.feedScrollView
                .contentOffset = .init(x: self.view.frame.width*2, y: 0)
        }
    }
    
    func topTabBarBinding() {
        viewModel.communityType
            .distinctUntilChanged()
            .bind(onNext: { [weak self] type in
                self?.moveIndicatorbar(targetIndex: type.rawValue)
            })
            .disposed(by: disposeBag)
        
        topTabBarCollectionView.rx.itemSelected
            .map { $0.item }
            .subscribe(onNext: { [weak self] idx in
                guard let self else { return }
                self.viewModel.communityType.onNext(.init(rawValue: idx) ?? .total)
            })
            .disposed(by: disposeBag)
        
        feedScrollView.rx.didScroll
            .observe(on:MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] in
                guard let self else { return }
                let targetIndex = Int(feedScrollView.contentOffset.x/self.view.frame.width)
                let indexPath = IndexPath(item: targetIndex, section: 0)
                guard let cell = topTabBarCollectionView.cellForItem(at: indexPath) as? TopTabBarItemCell else { return }
                
                indicatorView.snp.remakeConstraints {
                    $0.centerX.equalTo((self.view.frame.width/3)/2 + self.feedScrollView.contentOffset.x/3)
                    $0.width.equalTo(cell.getTitleFrameWidth())
                    $0.height.equalTo(3)
                    $0.centerY.equalTo(self.indicatorUnderLineView)
                }
                
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                
                if feedScrollView.contentOffset.x == 0 {
                    self.viewModel.communityType.onNext(.total)
                } else if feedScrollView.contentOffset.x == self.view.frame.width {
                    self.viewModel.communityType.onNext(.certification)
                } else if feedScrollView.contentOffset.x == self.view.frame.width*2 {
                    self.viewModel.communityType.onNext(.fitSite)
                }
            })
            .disposed(by: disposeBag)
    }
}
extension SearchViewController {
    private func createDataSoruce() -> RxCollectionViewSectionedReloadDataSource<SearchTotalSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<SearchTotalSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            switch item {
            case .certification(record: let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CertificationCell.identifier, for: indexPath) as! CertificationCell
        
                cell.configureCell(item)
                return cell
            case .fitSite(article: let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FitSiteCollectionCell.identifier, for: indexPath) as! FitSiteCollectionCell
                cell.configureCell(item: item)
                
                return cell
            }
        } configureSupplementaryView: {  dataSource, collectionView, kind, indexPath in
            switch kind {
            case SearchTotalHeaderView.certification:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SearchTotalHeaderView.certification,
                                                                                 withReuseIdentifier: SearchTotalHeaderView.identifier,
                                                                                 for: indexPath) as! SearchTotalHeaderView
                headerView.title = "운동 인증"
                
                headerView.didTapMore = { [weak self] in
                    guard let self else { return }
                    self.feedScrollView
                        .contentOffset = .init(x: self.view.frame.width, y: 0)
                    self.viewModel.communityType.onNext(.certification)
                }
                
                return headerView
            default:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SearchTotalHeaderView.fitSite,
                                                                                 withReuseIdentifier: SearchTotalHeaderView.identifier,
                                                                                 for: indexPath) as! SearchTotalHeaderView
                headerView.title = "핏사이트"
                headerView.didTapMore = { [weak self] in
                    guard let self else { return }
                    self.feedScrollView
                        .contentOffset = .init(x: self.view.frame.width*2, y: 0)
                    self.viewModel.communityType.onNext(.fitSite)
                }
                return headerView
            }
        }
    }
}


extension SearchViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { (sectionIndex: Int,
                                                              environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createCertificationSection()
            default: return self.createfitSiteSection()
            }
        }
        
        return layout
    }
    
    private func createCertificationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute((self.view.frame.width-60)/2),
                                              heightDimension: .absolute(((self.view.frame.width-60)/2)*1.33))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2.0),
                                               heightDimension: .estimated(0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                   heightDimension: .estimated(40)),
                                                                 elementKind: SearchTotalHeaderView.certification,
                                                                 alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        section.contentInsets = .init(top: 0, leading: 0, bottom: 45, trailing: 0)
        return section
    }
    
    private func createfitSiteSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(200))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(self.view.frame.width-40),
                                               heightDimension: .estimated(200))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        group.interItemSpacing = .fixed(5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                   heightDimension: .estimated(40)),
                                                                 elementKind: SearchTotalHeaderView.fitSite,
                                                                 alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createCertificationLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute((self.view.frame.width-45)/2),
                                              heightDimension: .absolute(((self.view.frame.width-45)/2)*1.33))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        group.interItemSpacing = .fixed(5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.orthogonalScrollingBehavior = .none
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createTopTabBar() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/3),
                                                            heightDimension: .absolute(50)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .absolute(50)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension SearchViewController {
    private func emptyResultBinding() {
        fitSiteTableView.backgroundView = fitSiteBackGroundView
        certificationCollectionView.backgroundView = certificationBackGroundView
        viewModel.searchText
            .bind(onNext: { [weak self] text in
                self?.certificationBackGroundView.configureLabel(text: text)
                self?.fitSiteBackGroundView.configureLabel(text: text)
            })
            .disposed(by: disposeBag)
        
        viewModel.fitSiteFeedList
            .map { !$0.isEmpty }
            .bind(to: fitSiteBackGroundView.rx.isHidden)
            .disposed(by: disposeBag)
            
        viewModel.certificationFeedList
            .map { !$0.isEmpty }
            .bind(to: certificationBackGroundView.rx.isHidden)
            .disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] text in
                self?.toggleResultHidden(isHidden: true)
                self?.recommendView.isHidden = false
            })
            .disposed(by: disposeBag)
    }
}
