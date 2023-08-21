//
//  FitSiteDetailViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class FitSiteDetailViewController: BaseViewController {
    private let viewModel: FitSiteDetailViewModel
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
        $0.register(FitSiteDetailCell.self, forCellWithReuseIdentifier: FitSiteDetailCell.identifier)
        $0.backgroundColor = .bgDefault
    }
    
    private let commentInputView = CommentInputView()
    
    private let moreButton = UIBarButtonItem(image: UIImage(named: "ic_more")?.withRenderingMode(.alwaysOriginal),
                                             style: .plain,
                                             target: nil,
                                             action: nil)
    
    init(viewModel: FitSiteDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.responseToKeyboardHegiht(commentInputView)
        self.tabBarController?.tabBar.isHidden = true
        viewModel.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - SetupBinding
    override func setupBinding() {
        let input = FitSiteDetailViewModel.Input(commentRegistTap: commentInputView.registButton.rx.tap
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
                self?.commentInputView.commentInputView.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        viewModel.reportHandler
            .bind(onNext: { [weak self] code in
                var message = ""
                switch code {
                case 2000: message = "신고가 완료되었습니다."
                case 4051: message = "존재하지 않는 댓글입니다."
                case 4061: message = "이미 신고되어 검토중인 내용입니다."
                case 4062: message = "자신의 글은 신고가 불가능합니다."
                case 4031: message = "존재하지 않는 게시글 입니다."
                default: message = "알 수 없는 에러"
                }
                self?.notiAlert(message)
            })
            .disposed(by: disposeBag)
        
        moreButton.rx.tap.asObservable()
            .withLatestFrom(self.viewModel.detailSource)
            .map { item -> Bool in
                guard let userIdString = KeychainManager.read("userId"),
                      let userId = Int(userIdString) else { return false }
                return item.userInfo.ownerId == userId
            }
            .subscribe(onNext: { [weak self] isMyArticle in
                if isMyArticle {
                    self?.showMyArticleMoreInfo()
                } else {
                    self?.showOtherArticleMoreInfo()
                }
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
            .bind(onNext: { [weak self] error in
                if let fitSiteError = error as? FitSiteError,
                   fitSiteError == .invalidArticle {
                    self?.showInvalidArticleNoti()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.deleteFeedHandler
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isSuccess in
                if isSuccess {
                    self?.showDeleteCompleteAlert()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        navigationItem.rightBarButtonItem = moreButton
    }
    
    // MARK: - 화면 이동
    private func showDeleteCompleteAlert() {
        let alert = StandardAlertController(title: "삭제 완료", message: "정상적으로 삭제가 완료되었습니다.")
        let ok = StandardAlertAction(title: "확인", style: .basic) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(ok)
        
        self.present(alert, animated: false)
    }
    
    private func showDeleteAlert() {
        let alert = StandardAlertController(title: "게시글을 삭제하시겠어요?", message: "해당 게시글은 영구 삭제됩니다.")
        let cancel = StandardAlertAction(title: "취소", style: .cancel)
        let delete = StandardAlertAction(title: "삭제", style: .basic) { [weak self] _ in
            self?.viewModel.deleteArticle()
        }
        
        alert.addAction([cancel,delete])
        
        self.present(alert, animated: false)
    }
    
    private func showInvalidArticleNoti() {
        let alert = StandardAlertController(title: "존재하지 않는 게시글입니다.", message: "차단 또는 삭제된 게시글")
        let ok = StandardAlertAction(title: "확인", style: .basic) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(ok)
        
        self.present(alert, animated: false)
    }
    
    private func showMyArticleMoreInfo() {
        let actionSheet = StandardActionSheetController()
        let edit = StandardActionSheetAction(title: "수정하기") { [weak self] _ in
            guard let self,
            let info = viewModel.fitSiteModel else { return }
            self.showEditFitSite(info: info)
        }
        edit.configuration?.baseForegroundColor = .textDefault
        let delete = StandardActionSheetAction(title: "삭제하기") { [weak self] _ in
            self?.showDeleteAlert()
        }
        
        actionSheet.addAction([edit,delete])
        
        self.present(actionSheet, animated: false)
    }
    
    private func showEditFitSite(info: FitSiteDetailDTO) {
        let usecase = EditFitSiteUseCase(fitSiteRepo: FitSiteRepository(service: ArticleService()),
                                       userRepo: UserRepository(service: UserService()))
        let editFitSiteVC = EditFitSiteViewController(EditFitSiteViewModel(usecase: usecase,
                                                                           info: info))
        
        self.navigationController?.pushViewController(editFitSiteVC, animated: true)
    }
    
    private func showOtherArticleMoreInfo() {
        let actionSheet = StandardActionSheetController()
        let reportArticle = StandardActionSheetAction(title: "게시글 신고하기") { [weak self] _ in
            self?.presentReportArticleAlert()
        }
        let reportUser = StandardActionSheetAction(title: "사용자 신고하기") { [weak self] _ in
            self?.showReportUserAlert()
        }
        
        actionSheet.addAction([reportArticle, reportUser])
        
        self.present(actionSheet, animated: false)
    }
    
    private func showReportUserAlert() {
        let alert = StandardAlertController(title: "사용자를 신고하시겠습니까?", message: "신고된 사용자는 차단되어 글과 댓글이\n숨겨지고, 차단은 취소할 수 없습니다.")
        let report = StandardAlertAction(title: "신고", style: .basic) { [weak self] _ in
            self?.viewModel.reportUser()
        }
        let cancel = StandardAlertAction(title: "취소", style: .cancel)
        alert.addAction([cancel,report])
        
        self.present(alert, animated: false)
    }
    
    private func presentReportArticleAlert() {
        let alert = StandardAlertController(title: "게시글을 신고하시겠습니까?", message: "신고된 게시글은 운영진 확인 후 삭제되고,\n신고는 취소할 수 없습니다.")
        let cancel = StandardAlertAction(title: "취소", style: .cancel)
        let delete = StandardAlertAction(title: "신고", style: .basic) { [weak self] _ in
            self?.viewModel.reportFitSite()
        }
        
        alert.addAction([cancel,delete])
        
        self.present(alert, animated: false)
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
extension FitSiteDetailViewController {
    private func createDataSoruce() -> RxCollectionViewSectionedReloadDataSource<FitSiteDetailSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<FitSiteDetailSectionModel> {
            (dataSource, collectionView, indexPath, item) in
            switch item {
            case .detailInfo(info: let info):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FitSiteDetailCell.identifier, for: indexPath) as! FitSiteDetailCell
                cell.configureCell(item: info)
                cell.delegate = self
                
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

extension FitSiteDetailViewController: CommentCellDelegate {
    func toggleLike(commentId: Int, completion: @escaping (LikeCommentDTO) -> Void) {
        self.viewModel.toggleLike(commentId: commentId)
            .subscribe(onSuccess: { item in
                completion(item)
            })
            .disposed(by: disposeBag)
    }
    
    func didClickMoreButton(ownerId: Int, commentId: Int) {
        guard let userIdString = KeychainManager.read("userId"),
        let userId = Int(userIdString) else { return }
        let actionSheet = StandardActionSheetController()
        
        if ownerId == userId {
            let deleteComment = StandardActionSheetAction(title: "댓글 삭제하기") { [weak self] _ in
                self?.presentDeleteAlert(commentId: commentId)
            }
            actionSheet.addAction(deleteComment)
        } else {
            let reportUser = StandardActionSheetAction(title: "사용자 신고하기") { [weak self] _ in
                self?.showReportUserAlert()
            }
            let reportComment = StandardActionSheetAction(title: "댓글 신고하기") { [weak self] _ in
                self?.presentReportCommentAlert(commentId: commentId)
            }
            actionSheet.addAction([reportComment,reportUser])
        }
        
        self.present(actionSheet, animated: false)
    }
    
    private func presentDeleteAlert(commentId: Int) {
        let alert = StandardAlertController(title: "댓글을 삭제하시겠어요?", message: "해당 댓글은 영구삭제됩니다.")
        let cancel = StandardAlertAction(title: "취소", style: .cancel)
        let delete = StandardAlertAction(title: "삭제", style: .basic) { [weak self] _ in
            self?.viewModel.deleteComment(commentId: commentId)
        }
        
        alert.addAction([cancel,delete])
        
        self.present(alert, animated: false)
    }
    
    private func presentReportCommentAlert(commentId: Int) {
        let alert = StandardAlertController(title: "댓글을 신고하시겠습니까?", message: "신고된 댓글은 운영진 확인 후 삭제되고,\n신고는 취소할 수 없습니다.")
        let cancel = StandardAlertAction(title: "취소", style: .cancel)
        let delete = StandardAlertAction(title: "신고", style: .basic) { [weak self] _ in
            self?.viewModel.reportComment(commentId: commentId)
        }
        
        alert.addAction([cancel,delete])
        
        self.present(alert, animated: false)
    }
}

extension FitSiteDetailViewController: FitSiteDetailCellDelegate {
    func toggleLike(articleId: Int, completion: @escaping (LikeFitSiteDTO) -> Void) {
        self.viewModel.toggleLikeFitSite(articleId: articleId)
            .subscribe(onSuccess: { item in
                completion(item)
            })
            .disposed(by: disposeBag)
    }
    
    func toggleScrap(articleId: Int, completion: @escaping (FitSiteScrapDTO) -> Void) {
        self.viewModel.toggleScrapFitSite(articleId: articleId)
            .subscribe(onSuccess: { item in
                completion(item)
            })
            .disposed(by: disposeBag)
    }
}

extension FitSiteDetailViewController {
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
                                                            heightDimension: .estimated(100)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(self.view.frame.width),
                                                                         heightDimension: .estimated(100)),
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

