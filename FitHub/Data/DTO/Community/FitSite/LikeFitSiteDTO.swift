//
//  LikeFitSiteDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import Foundation

struct LikeFitSiteDTO: Decodable {
    let articleId: Int
    let articleLikes: Int
    let isLiked: Bool
}
