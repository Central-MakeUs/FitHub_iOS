//
//  FitSiteDetailViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import Foundation
import RxSwift

final class FitSiteDetailViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private let usecase: FitSiteDetailUseCaseProtocol
    private let articleId: Int
    
    private var currentCommentPage = 0
    private var isPaging = false
    private var isLastPage: Bool = false
    
    // MARK: - Output
    let recordDataSoruce = BehaviorSubject<[FitSiteDetailSectionModel]>(value: [])
    let errorHandler = PublishSubject<Error>()
    let reportHandler = PublishSubject<Int>()
    
    //MARK: - Input
    let detailSource = PublishSubject<FitSiteDetailDTO>()
    let commentListSource = BehaviorSubject<[CommentDTO]>(value: [])
    let commentInfoSource = PublishSubject<FetchCommentDTO>()
    
    struct Input {
        let commentRegistTap: Observable<String>
        let didScroll: Observable<(CGFloat,CGFloat,CGFloat)>
    }
    
    struct Output {
        let commentComplete = PublishSubject<Bool>()
    }
    
    init(usecase: FitSiteDetailUseCaseProtocol,
         articleId: Int) {
        self.usecase = usecase
        self.articleId = articleId
        
        commentInfoSource
            .map { $0.commentList } // 새거 $0
            .withLatestFrom(self.commentListSource, // 헌거
                            resultSelector: {
                var newComment = $1
                newComment.append(contentsOf: $0)
                return newComment
            })
            .subscribe(commentListSource)
            .disposed(by: disposeBag)
        
        commentInfoSource
            .subscribe(onNext: { [weak self] info in
                self?.isLastPage = info.isLast
            })
            .disposed(by: disposeBag)
        self.fetchFitSiteDetail()
        self.fetchComment()
        
        let detail = detailSource.map {
            FitSiteDetailSectionModel.Item.detailInfo(info: $0)
        }
        .map { [FitSiteDetailSectionModel.detailInfo(items: [$0])] }
        
        let comment = commentListSource.asObservable()
            .map { $0.map { FitSiteDetailSectionModel.Item.comments(commentsInfo: $0) } }
            .map { [FitSiteDetailSectionModel.comments(items: $0)]}
        
        Observable.combineLatest(detail, comment)
            .map { $0.0 + $0.1 }
            .subscribe(recordDataSoruce)
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.commentRegistTap
            .flatMap { self.usecase.createComment(id: self.articleId, contents: $0).asObservable()
                    .catchAndReturn(false)
            }
            .subscribe(onNext: { [weak self] isSuccess in
                if isSuccess {
                    self?.resetPaging()
                    self?.fetchComment()
                    self?.fetchFitSiteDetail()
                    output.commentComplete.onNext(true)
                } else {
                    output.commentComplete.onNext(false)
                    //TODO: 댓글작성실패
                }
            })
            .disposed(by: disposeBag)
        
        input.didScroll
            .filter { $0.1 != 0.0 }
            .subscribe(onNext: { [weak self] (offsetY, contentHeight, frameHeight) in
                guard let self else { return }
                if offsetY > (contentHeight - frameHeight) {
                    if self.isPaging == false && !isLastPage { self.paging() }
                }
            })
            .disposed(by: disposeBag)
            
        return output
    }
    
    func reportFitSite() {
        usecase.reportFitSite(articleId: articleId)
            .subscribe(onSuccess: { [weak self] code in
                self?.reportHandler.onNext(code)
            })
            .disposed(by: disposeBag)
    }
    
    func toggleLikeFitSite(articleId: Int) -> Single<LikeFitSiteDTO> {
        return usecase.toggleLikeFitSite(articleId: articleId)
    }
    
    func toggleLike(commentId: Int) -> Single<LikeCommentDTO> {
        return self.usecase.toggleCommentLike(id: articleId, commentId: commentId)
    }
    
    func deleteComment(commentId: Int) {
        self.usecase.deleteComment(id: articleId, commentId: commentId)
            .subscribe(onSuccess: { [weak self] isSuccess in
                if isSuccess {
                    self?.resetPaging()
                    self?.fetchComment()
                    self?.fetchFitSiteDetail()
                } else {
                    // TODO: 다른사람댓글 or type다름 or 댓글이 업석나 운동인증 존재 안하거나 게시글 없거나 처리
                }
            }, onFailure: { [weak self] error in
                self?.errorHandler.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    func reportComment(commentId: Int) {
        self.usecase.reportComment(commentId: commentId)
            .subscribe(onSuccess: { [weak self] code in
                self?.reportHandler.onNext(code)
            },onFailure: { [weak self] error in
                self?.errorHandler.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}

extension FitSiteDetailViewModel {
    private func fetchFitSiteDetail() {
        usecase.fetchFitSiteDetail(articleId: articleId)
            .subscribe(onSuccess: { [weak self] res in
                self?.detailSource.onNext(res)
            }, onFailure: { [weak self] error in
                self?.errorHandler.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchComment() {
        usecase.fetchComments(page: currentCommentPage, id: articleId)
            .subscribe(onSuccess: { [weak self] res in
                self?.commentInfoSource.onNext(res)
            }, onFailure: { [weak self] error in
                self?.errorHandler.onNext(error)
            },onDisposed: { [weak self] in
                self?.isPaging = false
            })
            .disposed(by: disposeBag)
    }
    
    private func paging() {
        self.isPaging = true
          currentCommentPage += 1
          fetchComment()
    }
    
    private func resetPaging() {
        currentCommentPage = 0
        isLastPage = false
        commentListSource.onNext([])
    }
}
