//
//  CertifiactionDetailUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import Foundation
import RxSwift

protocol CertifiactionDetailUseCaseProtocol {
    func createComment(id: Int, contents: String) -> Single<Bool>
    func fetchComments(page: Int, id: Int)->Single<FetchCommentDTO>
    func toggleCommentLike(id: Int, commentId: Int)->Single<LikeCommentDTO>
    func reportComment(commentId: Int)->Single<Int>
    func deleteComment(id: Int, commentId: Int)->Single<Bool>
    func fetchCertificationDetail(recordId: Int)->Single<CertificationDetailDTO>
    func reportCertification(recordId: Int)->Single<Int>
    func removeCertification(recordId: Int)->Single<Int>
    func toggleLikeCertification(recordId: Int)->Single<LikeCertificationDTO>
}

final class CertifiactionDetailUseCase: CertifiactionDetailUseCaseProtocol {
    private let certificationRepository: CertificationRepositoryInterface
    private let commentRepository: CommentRepositoryInterface
    
    init(certificationRepository: CertificationRepositoryInterface,
         commentRepository: CommentRepositoryInterface) {
        self.certificationRepository = certificationRepository
        self.commentRepository = commentRepository
    }
    
    func toggleLikeCertification(recordId: Int) -> Single<LikeCertificationDTO> {
        return certificationRepository.toggleLikeCertification(recordId: recordId)
    }
    
    func fetchCertificationDetail(recordId: Int)->Single<CertificationDetailDTO> {
        return certificationRepository.fetchCertificationDetail(recordId: recordId)
    }
    
    func reportCertification(recordId: Int)->Single<Int> {
        return certificationRepository.reportCertification(recordId: recordId)
    }
    
    func removeCertification(recordId: Int)->Single<Int> {
        return certificationRepository.removeCertification(recordId: recordId)
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
