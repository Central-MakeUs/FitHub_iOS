//
//  CertificationDetailViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class CertificationDetailViewController: BaseViewController {
    private let viewModel: CertificationDetailViewModel
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
        $0.register(CertificationDetailCell.self, forCellWithReuseIdentifier: CertificationDetailCell.identifier)
        $0.backgroundColor = .bgDefault
    }
    
    private let commentInputView = CommentInputView()
    
    private let moreButton = UIBarButtonItem(image: UIImage(named: "ic_more")?.withRenderingMode(.alwaysOriginal),
                                             style: .plain,
                                             target: nil,
                                             action: nil)
    
    init(viewModel: CertificationDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - SetupBinding
    override func setupBinding() {
        let input = CertificationDetailViewModel.Input(commentRegistTap: commentInputView.registButton.rx.tap
            .asObservable()
            .compactMap { self.commentInputView.commentInputView.text },
                                                       didScroll: collectionView.rx.didScroll
            .map { [weak self] Void -> (offsetY: CGFloat, contentHeight: CGFloat, frameHeight: CGFloat) in
                guard let self else { return (0,0,0) }
                return (self.collectionView.contentOffset.y,
                        self.collectionView.contentSize.height,
                        self.collectionView.frame.height)
            }.asObservable())
        
        let output = viewModel.transform(input: input)
        
        let dataSource = createDataSoruce()
        
        self.viewModel.recordDataSoruce
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.commentComplete
            .subscribe(onNext: { [weak self] isSuccess in
                self?.commentInputView.commentInputView.text = ""
            })
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        navigationItem.rightBarButtonItem = moreButton
    }
    
    override func addSubView() {
        self.view.addSubview(collectionView)
        self.view.addSubview(commentInputView)
    }
    
    override func layout() {
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-54)
        }
        
        commentInputView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - DataSoruce
extension CertificationDetailViewController {
    private func createDataSoruce() -> RxCollectionViewSectionedReloadDataSource<CertificationDetailSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<CertificationDetailSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            switch item {
            case .detailInfo(info: let info):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CertificationDetailCell.identifier, for: indexPath) as! CertificationDetailCell
                cell.configureCell(item: info)
                
                return cell
            case .comments(commentsInfo: let comment):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
                cell.configureCell(item: comment)
                cell.delegate = self
                
                return cell
            }
        }
    }
}

extension CertificationDetailViewController: CommentCellDelegate {
    func toggleLike(commentId: Int, completion: @escaping (LikeCommentDTO) -> Void) {
        self.viewModel.toggleLike(commentId: commentId)
            .subscribe(onSuccess: { item in
                completion(item)
            })
            .disposed(by: disposeBag)
    }
}

extension CertificationDetailViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { (sectionIndex: Int,
                                                              environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createRecordInfoSection()
            default: return self.createCommentSection()
            }
        }
        
        return layout
    }
    
    private func createRecordInfoSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(1000)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(self.view.frame.width),
                                                                         heightDimension: .estimated(1000)),
                                                       subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
    
    private func createCommentSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(80)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .absolute(self.view.frame.width-40),
                                                                       heightDimension: .estimated(80)),
                                                     subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 20, bottom: 0, trailing: 20)
        section.orthogonalScrollingBehavior = .none
        
        return section
    }
}