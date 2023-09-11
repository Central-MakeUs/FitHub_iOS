//
//  EditFitSiteViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/11.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import PhotosUI

final class CreateFitSiteViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: CreateFitSiteViewModel

    private let completeButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
        $0.setTitle("등록", for: .normal)
        $0.setTitleColor(.textSub01, for: .normal)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.showsVerticalScrollIndicator = false
        $0.register(SportFooterView.self, forSupplementaryViewOfKind: SportFooterView.reuseIdentifier, withReuseIdentifier: SportFooterView.identifier)
        $0.register(SportHeaderView.self, forSupplementaryViewOfKind: SportHeaderView.reuseIdentifier, withReuseIdentifier: SportHeaderView.identifier)
        $0.register(HashTagFooterView.self, forSupplementaryViewOfKind: HashTagFooterView.reuseIdentifier, withReuseIdentifier: HashTagFooterView.identifier)
        $0.register(TitleCell.self, forCellWithReuseIdentifier: TitleCell.identifier)
        $0.register(FitSiteImageCell.self, forCellWithReuseIdentifier: FitSiteImageCell.identifier)
        $0.register(HashTagCell.self, forCellWithReuseIdentifier: HashTagCell.identifier)
        $0.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.identifier)
        $0.register(SportCell.self, forCellWithReuseIdentifier: SportCell.identifier)
        
        $0.backgroundColor = .clear
    }
    
    init(_ viewModel: CreateFitSiteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.gestureRecognizers = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFeedBackButton()
        responseToKeyboardHeightWithScrollView(collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Init
    override func configureNavigation() {
        super.configureNavigation()
        self.title = "게시글 작성하기"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completeButton)
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        let input = CreateFitSiteViewModel.Input(completeTap: completeButton.rx.tap.asObservable()
            .map { [weak self] _ in self?.view.endEditing(true) })
        
        let output = self.viewModel.transform(input: input)
        
        let dataSource = self.createDataSoruce()
        
        output.dataSource
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.completeEnable
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { isEnable in
                self.completeButton.isEnabled = isEnable
                if isEnable {
                    self.completeButton.setTitleColor(.primary, for: .normal)
                } else {
                    self.completeButton.setTitleColor(.textSub01, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        self.collectionView.rx.modelSelected(EditFitSiteSectionModel.Item.self)
            .subscribe(onNext: { [weak self] model in
                self?.view.endEditing(true)
                switch model {
                case .sport(item: let item):
                    self?.viewModel.selectedSportSource.accept(item)
                    self?.collectionView.reloadSections(.init(integer: 4))
                default: print("예외")
                }
            })
            .disposed(by: disposeBag)
        
        output.completePublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { isSuccess in
                if isSuccess {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.notiAlert("작성 실패: 서버 오류")
                }
            })
            .disposed(by: disposeBag)
        
        self.collectionView.rx.itemSelected
            .filter { $0.section == 2 }
            .map { $0.item }
            .subscribe(onNext: { [weak self] itemIdx in
                guard let self else { return }
                if itemIdx == 0 {
                    self.showPhotoAlbum()
                } else {
                    var newImages = self.viewModel.imageSource.value
                    newImages.remove(at: itemIdx)
                    self.viewModel.imageSource.accept(newImages)
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }

    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(collectionView)
    }
    
    override func layout() {
        self.collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - DataSoruce
extension CreateFitSiteViewController {
    private func createDataSoruce() -> RxCollectionViewSectionedReloadDataSource<EditFitSiteSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<EditFitSiteSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            switch item {
            case .title(string: _):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCell.identifier, for: indexPath) as! TitleCell
                cell.delegate = self
                
                return cell
            case .content(string: let text):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.identifier, for: indexPath) as! ContentCell
                cell.placeholder = "꿀팁을 공유하거나 운동과 관련해서 궁금한 점을 물어보세요."
                cell.delegate = self
                cell.configureCell(text: text)
                
                return cell
            case .image(image: let image):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FitSiteImageCell.identifier, for: indexPath) as! FitSiteImageCell
                cell.prepareForReuse()
                cell.configureCell(image: image)
                if indexPath.row == 0 {
                    cell.configureCameraCell(isEnable: true, count: self.viewModel.imageSource.value.count-1)
                }
                return cell
            case .hashtag(string: let string):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HashTagCell.identifier, for: indexPath) as! HashTagCell
                cell.configureLabel(string)
                cell.prepareForReuse()
                cell.delegate = self
                
                if indexPath == IndexPath(item: 0, section: 3) {
                    cell.configureAddCell(self.viewModel.addHashTagEnable.value)
                }
                return cell
            case .sport(item: let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportCell.identifier, for: indexPath) as! SportCell
                let selectedItem = self.viewModel.selectedSportSource.value
                
                cell.configureCell(item: item, selectedItem: selectedItem)
                
                return cell
            }
        } configureSupplementaryView: {  dataSource, collectionView, kind, indexPath in
            switch kind {
            case HashTagFooterView.reuseIdentifier:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: HashTagFooterView.reuseIdentifier,
                                                                                 withReuseIdentifier: HashTagFooterView.identifier,
                                                                                 for: indexPath) as! HashTagFooterView
                return footerView
            case SportHeaderView.reuseIdentifier:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SportHeaderView.reuseIdentifier,
                                                                                 withReuseIdentifier: SportHeaderView.identifier,
                                                                                 for: indexPath) as! SportHeaderView
                return headerView
                
            default:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: SportFooterView.reuseIdentifier,
                                                                                 withReuseIdentifier: SportFooterView.identifier,
                                                                                 for: indexPath)
                return footerView
            }
        }
    }
}

//MARK: - PHPicker Delegate
extension CreateFitSiteViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    private func showPhotoAlbum() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images
        let photoPickerVC = PHPickerViewController(configuration: configuration)
        photoPickerVC.delegate = self
        self.present(photoPickerVC, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        var images: [UIImage?] = [nil]
        results.forEach {
            let itemProvider = $0.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] result, error in
                    guard let image = result as? UIImage else { return }
                    images.append(image)
                    self?.viewModel.imageSource.accept(images)
                }
            }
        }
    }
}

// MARK: - Compositional
extension CreateFitSiteViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { (sectionIndex: Int,
                                                              environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createTitleSection()
            case 1: return self.createContentSection()
            case 2: return self.createFeedImageSection()
            case 3: return self.createHashTagSection()
            default: return self.createSportSection()
            }
        }
        
        return layout
    }
    
    private func createTitleSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(30)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(self.view.frame.width - 40),
                                                                         heightDimension: .estimated(30)),
                                                       subitems: [item])
        group.edgeSpacing = .init(leading: .fixed(20),
                                  top: .fixed(20),
                                  trailing: .fixed(20),
                                  bottom: .fixed(0))
        return NSCollectionLayoutSection(group: group)
    }
    
    private func createContentSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(33)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .absolute(self.view.frame.width - 40),
                                                                       heightDimension: .estimated(33)),
                                                     subitems: [item])
        
        group.edgeSpacing = .init(leading: .fixed(20),
                                  top: .fixed(0),
                                  trailing: .fixed(20),
                                  bottom: .fixed(0))
        
        let section = NSCollectionLayoutSection(group: group)
    
        section.orthogonalScrollingBehavior = .none
        
        return section
    }
    
    private func createFeedImageSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(100),
                                                            heightDimension: .absolute(100)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(4.0),
                                                                         heightDimension: .absolute(100)),
                                                       subitems: [item])
        group.interItemSpacing = .fixed(10)
        group.edgeSpacing = .init(leading: .fixed(20),
                                  top: .fixed(0),
                                  trailing: .fixed(20),
                                  bottom: .fixed(0))
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 40, leading: 0, bottom: 25, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
    
    private func createHashTagSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(30),
                                                            heightDimension: .fractionalHeight(1.0)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(self.view.frame.width-40),
                                                                         heightDimension: .absolute(32)),
                                                       subitems: [item])
        group.interItemSpacing = .fixed(8)
        group.edgeSpacing = .init(leading: .fixed(20),
                                  top: .fixed(0),
                                  trailing: .fixed(20),
                                  bottom: .fixed(8))
        
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                   heightDimension: .estimated(50)),
                                                                 elementKind: HashTagFooterView.reuseIdentifier,
                                                                 alignment: .bottom)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.boundarySupplementaryItems = [footer]
        
        return section
    }
    
    private func createSportSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.23),
                                                            heightDimension: .estimated(90)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(self.view.frame.width - 40),
                                                                         heightDimension: .estimated(90)),
                                                      subitems: [item])
        group.interItemSpacing = .flexible(8)
        group.edgeSpacing = .init(leading: .fixed(20), top: .fixed(15), trailing: .fixed(20), bottom: .fixed(0))
        
        let section = NSCollectionLayoutSection(group: group)
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                   heightDimension: .estimated(54)),
                                                                 elementKind: SportHeaderView.reuseIdentifier,
                                                                 alignment: .top)
        
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                   heightDimension: .estimated(70)),
                                                                 elementKind: SportFooterView.reuseIdentifier,
                                                                 alignment: .bottom)
        
        section.boundarySupplementaryItems = [header,footer]
        
        return section
    }
}

// MARK: - Content
extension CreateFitSiteViewController: ContentCellDelegate {
    func changeContentFrame() {
        self.collectionView.reloadSections(IndexSet(integer: 2))
    }
    
    func changeContent(string: String) {
        self.viewModel.changeContent(string)
    }
}

// MARK: - Title
extension CreateFitSiteViewController: TitleCellDelegate {
    func changeTitleFrame() {
        self.collectionView.reloadSections(IndexSet(integer: 2))
    }

    func changeTitle(string: String) {
        self.viewModel.titleSource.onNext(string)
    }
}

//MARK: - HashTag
extension CreateFitSiteViewController: HashTagDelegate {
    func changeSize() {
        self.collectionView.reloadSections(IndexSet(integer: 3))
    }
    
    func addHashTag(_ text: String) {
        self.viewModel.addHashTag(text)
    }
    
    func deleteHashTag(_ text: String) {
        let newHashTag = self.viewModel.hashTagSource.value.filter { $0 != text }
        self.viewModel.hashTagSource.accept(newHashTag)
    }
}
