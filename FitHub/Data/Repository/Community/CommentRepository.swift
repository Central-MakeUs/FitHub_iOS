//
//  CommentRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/13.
//

import Foundation
import RxSwift

protocol CommentRepositoryInterface {
    func createComment(type: CommentType, id: Int, contents: String) -> Single<Bool>
    func fetchComments(type: CommentType, page: Int, id: Int)->Single<FetchCommentDTO>
    func toggleCommentLike(type: CommentType, id: Int, commentId: Int)->Single<LikeCommentDTO>
    func reportComment(commentId: Int)->Single<Int>
    func deleteComment(type: CommentType, id: Int, commentId: Int)->Single<Bool>
}

final class CommentRepository: CommentRepositoryInterface {
    private let service: CommentService
    
    init(service: CommentService) {
        self.service = service
    }
    
    func createComment(type: CommentType, id: Int, contents: String) -> Single<Bool> {
        return service.createComment(type: type, id: id, contents: contents)
    }
    
    func fetchComments(type: CommentType, page: Int, id: Int) -> Single<FetchCommentDTO> {
        return service.fetchComments(type: type, page: page, id: id)
    }
    
    func toggleCommentLike(type: CommentType, id: Int, commentId: Int) -> Single<LikeCommentDTO> {
        return service.toggleCommentLike(type: type, id: id, commentId: commentId)
    }
    
    func deleteComment(type: CommentType, id: Int, commentId: Int)->Single<Bool> {
        return service.deleteComment(type: type, id: id, commentId: commentId)
    }
    
    func reportComment(commentId: Int) -> Single<Int> {
        return service.reportComment(commentId: commentId)
    }
    
}
