//
//  EditCertifiactionViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import PhotosUI

final class EditCertifiactionViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: EditCertifiactionViewModel
    
    private let completeButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
        $0.setTitle("등록", for: .normal)
        $0.setTitleColor(.textDefault, for: .normal)
    }
    
//    private let scrollView = UIScrollView()
//    private lazy var stackView = UIStackView()
//
//    private let imageView = UIImageView().then {
//        $0.backgroundColor = .bgSub01
//        $0.contentMode = .scaleAspectFit
//    }
//
//    private let contentTexView = UITextView().then {
//        $0.textColor = .textSub02
//        $0.backgroundColor = .clear
//        $0.isScrollEnabled = false
//        $0.text = "오늘 운동은 어땠나요?느낀점을 작성해봐요"
//        $0.font = .pretendard(.bodyMedium01)
//    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        $0.register(HashTagCell.self, forCellWithReuseIdentifier: HashTagCell.identifier)
        $0.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.identifier)
        
        $0.backgroundColor = .clear
    }
    
    init(_ viewModel: EditCertifiactionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.textViewBinding()
        
    }
    
    //MARK: - Init
    override func configureNavigation() {
        super.configureNavigation()
        self.title = "운동 인증하기"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completeButton)
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        let dataSource = self.createDataSoruce()
    
        Observable.of([
            EditCertificationSectionModel.image(items: [.image(image: "image")]),
            EditCertificationSectionModel.content(items: [.content(string: "안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.안녕하세요. 기본 내용입니다.")]),
            EditCertificationSectionModel.hashtag(items: [.hashtag(string: "해시추가"),
                                                          .hashtag(string: "해시태그1"),
                                                          .hashtag(string: "해시태그테스트1234567"),
                                                          .hashtag(string: "마지막해시태그")])
        ])
        .bind(to: self.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
//        self.view.addSubview(self.scrollView)
//
//        self.scrollView.addSubview(self.stackView)
//
//        self.stackView.addSubview(self.imageView)
//        self.stackView.addSubview(self.contentTexView)
        
        self.view.addSubview(collectionView)
    }
    
    override func layout() {
//        self.scrollView.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview()
//            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
//        }
//
//        self.stackView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//
//        self.imageView.snp.makeConstraints {
//            $0.leading.trailing.top.equalToSuperview()
//            $0.width.equalTo(self.view.frame.width)
//            $0.height.equalTo(imageView.snp.width).multipliedBy(4.0/3.0)
//        }
//
//        self.contentTexView.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview().inset(20)
//            $0.top.equalTo(self.imageView.snp.bottom).offset(20)
//            $0.height.equalTo(30)
//            $0.bottom.equalToSuperview()
//        }
        self.collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    
}
// MARK: - DataSoruce
extension EditCertifiactionViewController {
    private func createDataSoruce() -> RxCollectionViewSectionedReloadDataSource<EditCertificationSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<EditCertificationSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            switch item {
            case .image(image: let image):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
                
                return cell
            case .content(string: let string):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.identifier, for: indexPath) as! ContentCell
                
                return cell
            case .hashtag(string: let string):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HashTagCell.identifier, for: indexPath) as! HashTagCell
                cell.configureLabel(string)
                return cell
            }
            
        }
    }
}

// MARK: - Compositional
extension EditCertifiactionViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { (sectionIndex: Int,
                                                              environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(1.33))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                return NSCollectionLayoutSection(group: group)
            } else if sectionIndex == 1 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(33))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(self.view.frame.width - 40),
                                                       heightDimension: .estimated(33))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                group.edgeSpacing = .init(leading: .fixed(20),
                                          top: .fixed(20),
                                          trailing: .fixed(20),
                                          bottom: .fixed(0))
                
                let section = NSCollectionLayoutSection(group: group)
            
                section.orthogonalScrollingBehavior = .none
                
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(30),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(32))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(8)
                group.edgeSpacing = .init(leading: .fixed(20),
                                          top: .fixed(0),
                                          trailing: .fixed(20),
                                          bottom: .fixed(8))
                
                return NSCollectionLayoutSection(group: group)
            }
        }
        
        return layout
    }
}

//extension EditCertifiactionViewController {
//    private func textViewBinding() {
//        contentTexView.rx
//              .didChange
//              .subscribe(onNext: { [weak self] in
//                  guard let self = self else { return }
//                  let size = CGSize(width: self.contentTexView.frame.width, height: .infinity)
//                  let estimatedSize = self.contentTexView.sizeThatFits(size)
//
//                  contentTexView.snp.updateConstraints {
//                      $0.height.equalTo(estimatedSize.height)
//                  }
//              })
//              .disposed(by: disposeBag)
//
//        contentTexView.rx.didBeginEditing
//            .bind{
//                if self.contentTexView.text == "오늘 운동은 어땠나요?느낀점을 작성해봐요" {
//                    self.contentTexView.text = ""
//                }
//                self.contentTexView.textColor = .textDefault
//            }.disposed(by: disposeBag)
//
//        contentTexView.rx.didEndEditing
//            .bind{
//                if self.contentTexView.text.count == 0 {
//                    self.contentTexView.text = "오늘 운동은 어땠나요?느낀점을 작성해봐요"
//                    self.contentTexView.textColor = .textSub02
//                }
//            }.disposed(by: disposeBag)
//    }
//}
