//
//  FetchCommentDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/13.
//

import Foundation

class FetchCommentDTO: Decodable {
    let commentList: [CommentDTO]
    let listSize: Int
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool
}

class CommentDTO: Decodable {
    let commentId: Int
    let userInfo: UserInfoDTO
    let contents: String
    let likes: Int
    let isLiked: Bool
    let createdAt: String
}
