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
    
    private lazy var topTabbar: FitHubTopTabbar = {
        let tabbar = FitHubTopTabbar([TopTabbarItem("운동인증"),
                                      TopTabbarItem("핏사이트")])
        
        return tabbar
    }()
    
    private lazy var categoryCollectionView = UICollectionView(frame: .zero,
                                                               collectionViewLayout: self.createLayout()).then {
        $0.backgroundColor = .clear
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
    }
    
    private lazy var certificationCollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: createCertificationLayout()).then {
        $0.showsVerticalScrollIndicator = false
        $0.register(CertificationCell.self, forCellWithReuseIdentifier: CertificationCell.identifier)
        $0.backgroundColor = .clear
    }
    
    private let sortSwitchView = SortSwitchView(frame: .zero)
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ConfigureUI
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
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
        
        Observable.of(["전체","전체","테니스","배드민턴용","전체","전체","전체"])
            .bind(to: self.certificationCollectionView.rx
                .items(cellIdentifier: CertificationCell.identifier,
                       cellType: CertificationCell.self)) { index, name, cell in
                //TODO: 게시글 클릭시
            }
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
            
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(topTabbar)
        self.view.addSubview(categoryCollectionView)
        self.view.addSubview(sortSwitchView)
        self.view.addSubview(certificationCollectionView)
        self.view.addSubview(actionSheetBackView)
        self.view.addSubview(floatingButton)
        self.view.addSubview(createActionSheet)
    }
    
    //MARK: - layout
    override func layout() {
        self.topTabbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(6)
            $0.height.equalTo(50)
        }
        
        self.categoryCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(self.topTabbar.snp.bottom).offset(15)
            $0.height.equalTo(32)
        }
        
        self.sortSwitchView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(20)
        }
        
        self.certificationCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.sortSwitchView.snp.bottom).offset(15)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
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
}

