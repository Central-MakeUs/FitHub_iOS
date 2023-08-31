//
//  OtherProfileViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import UIKit
import RxSwift
import RxCocoa

final class OtherProfileViewController: BaseViewController {
    private let viewModel: OtherProfileViewModel
    
    private let moreButton = UIBarButtonItem(image: UIImage(named: "ic_more")?.withRenderingMode(.alwaysOriginal),
                                             style: .plain,
                                             target: nil,
                                             action: nil)

    private let feedScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .bgSub01
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .textDefault
        $0.font = .pretendard(.titleMedium)
        $0.text = "사용자명"
    }
    
    private let exerciseCardView = MyPageExerciseCardView()
    
    private let articleTitleLabel = UILabel().then {
        $0.font = .pretendard(.bodyLarge02)
        $0.textColor = .textDefault
        $0.text = "작성글"
    }
    
    private let indicatorUnderLineView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .iconDefault
    }
    
    private lazy var categoryCollectionView = UICollectionView(frame: .zero,
                                                               collectionViewLayout: self.createLayout()).then {
        $0.bounces = false
        $0.backgroundColor = .clear
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
    }
    
    private let fitSiteTableView = UITableView().then {
        $0.isScrollEnabled = false
        $0.separatorStyle = .none
        $0.register(OtherFitSiteCell.self, forCellReuseIdentifier: OtherFitSiteCell.identifier)
        $0.backgroundColor = .bgDefault
    }
    
    init(viewModel: OtherProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.gestureRecognizers = nil
        setDefaultView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .bgDefault
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        navigationItem.rightBarButtonItem = moreButton
    }
    
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
        
        viewModel.otherUserInfo
            .subscribe(onNext: { [weak self] info in
                self?.profileImageView.kf.setImage(with: URL(string: info.profileUrl ?? ""))
                self?.nameLabel.text = info.nickname
                self?.exerciseCardView.configureInfo(info.mainExerciseInfo)
                self?.exerciseCardView.titleLabel.text = "메인 운동"
            })
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(CategoryDTO.self)
            .map { $0.id }
            .bind(to: viewModel.selectedCategory)
            .disposed(by: disposeBag)
        
        fitSiteTableView.rx.didScroll
            .map { [weak self] Void -> (offsetY: CGFloat, contentHeight: CGFloat, frameHeight: CGFloat) in
                guard let self else { return (0,0,0) }
                return (self.fitSiteTableView.contentOffset.y,
                        self.fitSiteTableView.contentSize.height,
                        self.fitSiteTableView.frame.height)
            }
            .bind(to: viewModel.didScroll)
            .disposed(by: disposeBag)
        
        viewModel.fitSiteFeedList
            .bind(to: self.fitSiteTableView.rx.items(cellIdentifier: OtherFitSiteCell.identifier, cellType: OtherFitSiteCell.self)) { index, item, cell in
                
                cell.configureCell(item: item)
            }
            .disposed(by: disposeBag)
        
        viewModel.fitSiteFeedList
            .bind(onNext: { [weak self] info in
                if info.isEmpty {
                    self?.fitSiteTableView.snp.updateConstraints {
                        $0.height.equalTo(114)
                    }
                    self?.fitSiteTableView.backgroundView?.isHidden = false
                } else {
                    self?.fitSiteTableView.backgroundView?.isHidden = true
                    self?.fitSiteTableView.snp.updateConstraints {
                        $0.height.equalTo(114*info.count)
                    }
                }
                
                self?.loadViewIfNeeded()
            })
            .disposed(by: disposeBag)
        
        self.fitSiteTableView.rx.modelSelected(ArticleDTO.self)
            .map { $0.articleId }
            .bind(onNext: { [weak self] articleId in
                self?.pushFitSiteDetail(articleId: articleId)
            })
            .disposed(by: disposeBag)
        
        moreButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showMoreInfo()
            })
            .disposed(by: disposeBag)
        
        viewModel.reportUserHandler
            .bind(onNext: { [weak self] code in
                switch code {
                case 2000:
                    let alert = StandardAlertController(title: "신고 완료", message: "정상적으로 신고가 완료되었습니다.")
                    let ok = StandardAlertAction(title: "확인", style: .basic) { [weak self] _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    
                    self?.present(alert, animated: false)
                case 4013: self?.notiAlert("존재하지 않는 유저입니다.")
                case 4062: self?.notiAlert("이미 신고 완료된 유저입니다.")
                case 4063: self?.notiAlert("자기 자신을 신고할 수 없습니다.")
                default: self?.notiAlert("알 수 없는 오류\n관리자에게 문의해주세요.")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.errorHandler
            .bind(onNext: { [weak self] code in
                var title = "서버 에러"
                var message = "사용자 정보를 불러올 수 없습니다."
                
                if code == 4013 || code == 4064 {
                    title = "알 림"
                    message = "삭제 또는 차단되어 불러올 수 없는 사용자 입니다."
                }
                let alert = StandardAlertController(title: title, message: message)
                let ok = StandardAlertAction(title: "확인", style: .basic) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                alert.addAction(ok)
                
                self?.present(alert, animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func pushFitSiteDetail(articleId: Int) {
        let usecase = FitSiteDetailUseCase(commentRepository: CommentRepository(service: CommentService()),
                                           fitSiteRepository: FitSiteRepository(service: ArticleService()),
                                           communityRepository: CommunityRepository(UserService(),
                                                                                    certificationService: CertificationService(), articleService: ArticleService()))
        let fitSiteDetailVC = FitSiteDetailViewController(viewModel: FitSiteDetailViewModel(usecase: usecase,
                                                                                            articleId: articleId))
        
        self.navigationController?.pushViewController(fitSiteDetailVC, animated: true)
    }
    
    private func showMoreInfo() {
        let actionSheet = StandardActionSheetController()
        let reportUser = StandardActionSheetAction(title: "사용자 신고/차단하기") { [weak self] _ in
            self?.showReportUserAlert()
        }
        
        actionSheet.addAction(reportUser)
        
        self.present(actionSheet, animated: false)
    }
    
    private func showReportUserAlert() {
        let alert = StandardAlertController(title: "사용자를 신고/차단 하시겠습니까?", message: "신고된 사용자는 차단되어 글과 댓글이\n숨겨지고, 차단은 취소할 수 없습니다.")
        let report = StandardAlertAction(title: "신고", style: .basic) { [weak self] _ in
            self?.viewModel.reportUser()
        }
        let cancel = StandardAlertAction(title: "취소", style: .cancel)
        alert.addAction([cancel,report])
        
        self.present(alert, animated: false)
    }
    
    override func addSubView() {
        self.view.addSubview(feedScrollView)
        
        [profileImageView,nameLabel,exerciseCardView, articleTitleLabel, indicatorUnderLineView, indicatorView, categoryCollectionView, fitSiteTableView].forEach {
            self.feedScrollView.addSubview($0)
        }
    }
    
    override func layout() {
        feedScrollView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.width.height.equalTo(80)
            $0.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(10)
        }
        
        exerciseCardView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(15)
            $0.height.equalTo(122)
            $0.width.equalTo(self.view.frame.width-40)
            $0.centerX.equalToSuperview()
        }
        
        articleTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(exerciseCardView.snp.bottom).offset(32)
        }
        
        indicatorUnderLineView.snp.makeConstraints {
            $0.width.equalTo(self.view.frame.width)
            $0.horizontalEdges.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(articleTitleLabel.snp.bottom).offset(12)
        }
        
        indicatorView.snp.makeConstraints {
            let width = "작성글".getTextContentSize(withFont: .pretendard(.bodyLarge02)).width
            $0.width.equalTo(width)
            $0.height.equalTo(3)
            $0.centerY.equalTo(indicatorUnderLineView)
            $0.leading.equalTo(articleTitleLabel)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(indicatorUnderLineView.snp.bottom).offset(15)
            $0.height.equalTo(32)
        }
        
        fitSiteTableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(20)
            $0.height.equalTo(114)
            $0.bottom.equalToSuperview()
        }
    }
}

extension OtherProfileViewController {
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

extension OtherProfileViewController {
    private func setDefaultView() {
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
    }
}
