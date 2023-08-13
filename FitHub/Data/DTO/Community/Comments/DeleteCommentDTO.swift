//
//  DeleteCommentDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/13.
//

import Foundation

struct DeleteCommentDTO: Decodable {
    let commentId: Int
    let deletedAt: String
}
