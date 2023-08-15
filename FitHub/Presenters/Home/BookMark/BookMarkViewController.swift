//
//  BookMarkViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import UIKit

final class BookMarkViewController: BaseViewController {
    private let viewModel: BookMarkViewModel
    
    private let fitSiteLabel = UILabel().then {
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textDefault
        $0.text = "핏사이트"
    }
    
    private let indicatorUnderLineView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .iconDefault
    }
    
    private let defaultView = BookMarkDefaultView().then {
        $0.isHidden = true
    }
        
    
    private lazy var categoryCollectionView = UICollectionView(frame: .zero,
                                                               collectionViewLayout: self.createLayout()).then {
        $0.backgroundColor = .bgDefault
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
    }
    
    private lazy var fitSiteTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.register(FitSiteCell.self, forCellReuseIdentifier: FitSiteCell.identifier)
        $0.backgroundColor = .bgDefault
        $0.backgroundView = defaultView
    }
    
    init(viewModel: BookMarkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.view.gestureRecognizers = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        title = "북마크"
    }
    
    override func setupBinding() {
        viewModel.category
            .bind(to: categoryCollectionView.rx.items(cellIdentifier: CategoryCell.identifier, cellType: CategoryCell.self)) { [weak self] index, item, cell in
                guard let self else { return }
                if let selectedItems = categoryCollectionView.indexPathsForSelectedItems,
                   selectedItems.isEmpty {
                    categoryCollectionView.selectItem(at: IndexPath(item: 0, section: 0),
                                                      animated: false,
                                                      scrollPosition: .centeredVertically)
                }
                cell.configureLabel(item.name)
            }
            .disposed(by: disposeBag)
            
        
        viewModel.articleFeedList
            .bind(to: fitSiteTableView.rx.items(cellIdentifier: FitSiteCell.identifier, cellType: FitSiteCell.self)) { index, item, cell in
                cell.configureCell(item: item)
            }
            .disposed(by: disposeBag)
        
        viewModel.articleFeedList
            .map { $0.isEmpty }
            .subscribe(onNext: { [weak self] in
                self?.defaultView.isHidden = !$0
            })
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(CategoryDTO.self)
            .map { $0.id }
            .bind(to: viewModel.selectedCategory)
            .disposed(by: disposeBag)
        
        defaultView.moveFitSteButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.showCommunityVC()
            })
            .disposed(by: disposeBag)
        
        fitSiteTableView.rx.didScroll
            .map { [weak self] Void -> (offsetY: CGFloat, contentHeight: CGFloat, frameHeight: CGFloat) in
                guard let self else { return (0,0,0) }
                return (self.fitSiteTableView.contentOffset.y,
                        self.fitSiteTableView.contentSize.height,
                        self.fitSiteTableView.frame.height)
            }
            .bind(to: viewModel.bookMarkDidScroll)
            .disposed(by: disposeBag)
        
        fitSiteTableView.rx.modelSelected(ArticleDTO.self)
            .map { $0.articleId }
            .bind(onNext: { [weak self] articleId in
                self?.pushFitSiteDetail(articleId: articleId)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 화면 이동
    private func pushFitSiteDetail(articleId: Int) {
        let usecase = FitSiteDetailUseCase(commentRepository: CommentRepository(service: CommentService()),
                                         fitSiteRepository: FitSiteRepository(service: ArticleService()))
        let fitSiteDetailVC = FitSiteDetailViewController(viewModel: FitSiteDetailViewModel(usecase: usecase,
                                                                                            articleId: articleId))
        
        self.navigationController?.pushViewController(fitSiteDetailVC, animated: true)
    }
    
    private func showCommunityVC() {
        self.tabBarController?.selectedIndex = 1
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    override func addSubView() {
        [fitSiteLabel, indicatorUnderLineView, indicatorView, categoryCollectionView, fitSiteTableView].forEach {
            self.view.addSubview($0)
        }
    }
    
    override func layout() {
        fitSiteLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(12)
        }
        
        indicatorUnderLineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(fitSiteLabel.snp.bottom).offset(14)
            $0.height.equalTo(1)
        }
        
        indicatorView.snp.makeConstraints {
            $0.leading.equalTo(fitSiteLabel.snp.leading)
            $0.height.equalTo(3)
            $0.centerY.equalTo(indicatorUnderLineView)
            let width = "핏사이트".getTextContentSize(withFont: .pretendard(.bodyLarge02)).width
            $0.width.equalTo(width)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(self.indicatorView.snp.bottom).offset(15)
            $0.height.equalTo(32)
        }
        
        fitSiteTableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(categoryCollectionView.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension BookMarkViewController {
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
}
