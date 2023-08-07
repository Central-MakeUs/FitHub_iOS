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
    
    private let searchBar = FitHubSearchBar()
    private let sortSwitchView = SortSwitchView(frame: .zero)
    private let contentView = UIView()    
    
    private let indicatorUnderLineView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .iconDefault
    }
    
    let testView = UIView().then {
        $0.backgroundColor = .red
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
        $0.isPagingEnabled = true
    }

    private lazy var certificationCollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: createCertificationLayout()).then {
        $0.showsVerticalScrollIndicator = false
        $0.register(CertificationCell.self, forCellWithReuseIdentifier: CertificationCell.identifier)
        $0.backgroundColor = .clear
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.usecase.fetchCertificationFeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setUpCategoryBinding()
    }
    
    //MARK: - ConfigureUI
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
        self.feedScrollView.delegate = self
    }
    
    //MARK: - ConfigureNavigation
    override func configureNavigation() {
        let noti = UIBarButtonItem(image: UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal),
                                   style: .plain, target: nil, action: nil)
        let bookmark = UIBarButtonItem(image: UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal),
                                       style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [noti,bookmark]
        
        self.navigationItem.titleView = searchBar
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        let input = CommunityViewModel.Input()
        
        let output = self.viewModel.transform(input: input)
        
        output.category
            .bind(to: self.categoryCollectionView.rx
                .items(cellIdentifier: CategoryCell.identifier,
                       cellType: CategoryCell.self)) { index, name, cell in
                cell.configureLabel(name.name)
            }
                       .disposed(by: disposeBag)
//
        output.certificationFeedList
            .bind(to: self.certificationCollectionView.rx
                .items(cellIdentifier: CertificationCell.identifier,
                       cellType: CertificationCell.self)) { index, item, cell in
                cell.configureCell(item)
            }
                       .disposed(by: disposeBag)
        
        Observable.of(["운동인증","핏사이트"])
            .bind(to: self.topTabBarCollectionView.rx.items(cellIdentifier: TopTabBarItemCell.identifier, cellType: TopTabBarItemCell.self)) { index, item, cell in
                cell.configureCell(text: item)
            }
            .disposed(by: disposeBag)
        
        //TODO: 게시글 클릭시처리도 해줘야함.
        
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
        
        self.createActionSheet.certificationButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.pushCreateCertificationVC()
                self?.closeCreateActionSheet()
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
    private func pushCreateCertificationVC() {
        let usecase = EditCertificationUseCase(repository: EditCertificationRepository(certificationService: CertificationService(),
                                                                                       authService: AuthService()))
        let editCertificationVC = EditCertificationViewController(EditCertificationViewModel(usecase: usecase))
        self.navigationController?.pushViewController(editCertificationVC, animated: true)
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
        self.feedScrollView.addSubview(sortSwitchView)
        self.feedScrollView.addSubview(testView)
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

        self.sortSwitchView.snp.makeConstraints {
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
            $0.top.equalTo(self.sortSwitchView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 40)
            $0.height.equalTo(contentView.snp.height)
        }
        
        testView.snp.makeConstraints {
            $0.leading.equalTo(self.certificationCollectionView.snp.trailing).offset(40)
            $0.top.equalToSuperview()
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
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.contentInsets = .init(top: 5, leading: 0, bottom: 0, trailing: 0)
        group.interItemSpacing = .fixed(5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
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
    
    func setUpCategoryBinding() {
        self.viewModel.targetIndex
            .bind(onNext: { [weak self] targetIndex in
                self?.moveIndicatorbar(targetIndex: targetIndex)
                //TODO: 화면 전환
            })
            .disposed(by: disposeBag)

        topTabBarCollectionView.rx.itemSelected
            .map { $0.item }
            .bind(to: self.viewModel.targetIndex)
            .disposed(by: disposeBag)
    }
}

extension CommunityViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let targetIndex = Int(scrollView.contentOffset.x/self.view.frame.width)
        let indexPath = IndexPath(item: targetIndex, section: 0)
        guard let cell = topTabBarCollectionView.cellForItem(at: indexPath) as? TopTabBarItemCell else { return }
        indicatorView.snp.remakeConstraints {
            $0.centerX.equalTo(self.view.frame.width/4 + scrollView.contentOffset.x/2)
            $0.width.equalTo(cell.getTitleFrameWidth())
            $0.height.equalTo(3)
            $0.centerY.equalTo(indicatorUnderLineView)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        if scrollView.contentOffset.x == self.view.frame.width {
            self.viewModel.targetIndex.onNext(1)
        } else if scrollView.contentOffset.x == 0 {
            self.viewModel.targetIndex.onNext(0)
        }
    }
}
