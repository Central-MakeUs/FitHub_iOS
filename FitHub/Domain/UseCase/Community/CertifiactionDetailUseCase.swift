//
//  CertifiactionDetailUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import Foundation
import RxSwift

protocol CertifiactionDetailUseCaseProtocol {
    func fetchCertificationDetail(recordId: Int)->Single<CertificationDetailDTO>
    func createComment(id: Int, contents: String) -> Single<Bool>
    func fetchComments(page: Int, id: Int)->Single<FetchCommentDTO>
    func toggleCommentLike(id: Int, commentId: Int)->Single<LikeCommentDTO>
    func reportComment(commentId: Int)->Single<Int>
    func deleteComment(id: Int, commentId: Int)->Single<Bool>
}

final class CertifiactionDetailUseCase: CertifiactionDetailUseCaseProtocol {
    private let detailRepository: CertificationDetailRepositoryInterface
    private let commentRepository: CommentRepositoryInterface
    
    init(detailRepository: CertificationDetailRepositoryInterface,
         commentRepository: CommentRepositoryInterface) {
        self.detailRepository = detailRepository
        self.commentRepository = commentRepository
    }
    
    func fetchCertificationDetail(recordId: Int)->Single<CertificationDetailDTO> {
        return detailRepository.fetchCertificationDetail(recordId: recordId)
    }
    
    func createComment(id: Int, contents: String) -> Single<Bool> {
        return commentRepository.createComment(type: .records, id: id, contents: contents)
    }
    
    func fetchComments(page: Int, id: Int) -> Single<FetchCommentDTO> {
        return commentRepository.fetchComments(type: .records, page: page, id: id)
    }
    
    func toggleCommentLike(id: Int, commentId: Int) -> Single<LikeCommentDTO> {
        return commentRepository.toggleCommentLike(type: .records, id: id, commentId: commentId)
    }
    
    func reportComment(commentId: Int)->Single<Int> {
        return commentRepository.reportComment(commentId: commentId)
    }
    
    func deleteComment(id: Int, commentId: Int)->Single<Bool> {
        return commentRepository.deleteComment(type: .records, id: id, commentId: commentId)
    }
}
