//
//  FitSiteDetailUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import Foundation
import RxSwift

protocol FitSiteDetailUseCaseProtocol {
    func createComment(id: Int, contents: String) -> Single<Bool>
    func fetchComments(page: Int, id: Int)->Single<FetchCommentDTO>
    func toggleCommentLike(id: Int, commentId: Int)->Single<LikeCommentDTO>
    func reportComment(commentId: Int)->Single<Int>
    func deleteComment(id: Int, commentId: Int)->Single<Bool>
    
    func fetchFitSiteDetail(articleId: Int)->Single<FitSiteDetailDTO>
    func toggleLikeFitSite(articleId: Int)->Single<LikeFitSiteDTO>
    func reportFitSite(articleId: Int)->Single<Int>
    func deleteFitSite(articleId: Int)->Single<Bool>
}

final class FitSiteDetailUseCase: FitSiteDetailUseCaseProtocol {
    private let commentRepository: CommentRepositoryInterface
    private let fitSiteRepository: FitSiteRepositoryInterface
    
    init(commentRepository: CommentRepositoryInterface,
         fitSiteRepository: FitSiteRepositoryInterface) {
        self.commentRepository = commentRepository
        self.fitSiteRepository = fitSiteRepository
    }
    
    func createComment(id: Int, contents: String) -> Single<Bool> {
        return commentRepository.createComment(type: .articles, id: id, contents: contents)
    }
    
    func fetchComments(page: Int, id: Int) -> Single<FetchCommentDTO> {
        return commentRepository.fetchComments(type: .articles, page: page, id: id)
    }
    
    func toggleCommentLike(id: Int, commentId: Int) -> Single<LikeCommentDTO> {
        return commentRepository.toggleCommentLike(type: .articles, id: id, commentId: commentId)
    }
    
    func reportComment(commentId: Int)->Single<Int> {
        return commentRepository.reportComment(commentId: commentId)
    }
    
    func deleteComment(id: Int, commentId: Int)->Single<Bool> {
        return commentRepository.deleteComment(type: .articles, id: id, commentId: commentId)
    }
    
    func fetchFitSiteDetail(articleId: Int)->Single<FitSiteDetailDTO> {
        return fitSiteRepository.fetchFitSiteDetail(articleId: articleId)
    }
    
    func toggleLikeFitSite(articleId: Int)->Single<LikeFitSiteDTO> {
        return fitSiteRepository.toggleLikeFitSite(articleId: articleId)
    }
    
    func reportFitSite(articleId: Int)->Single<Int> {
        return fitSiteRepository.reportFitSite(articleId: articleId)
    }
    
    func deleteFitSite(articleId: Int)->Single<Bool> {
        return fitSiteRepository.deleteFitSite(articleId: articleId)
    }
}