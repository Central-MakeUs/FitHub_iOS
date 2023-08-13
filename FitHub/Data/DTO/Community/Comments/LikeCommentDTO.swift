//
//  LikeCommentDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/13.
//

import Foundation

class LikeCommentDTO: Decodable {
    let commentId: Int
    let newLikes: Int
    let isLiked: Bool
}
