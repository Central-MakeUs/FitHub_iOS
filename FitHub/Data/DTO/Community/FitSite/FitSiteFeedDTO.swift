//
//  FitSiteFeedDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/09.
//

import Foundation

class FitSiteFeedDTO: Decodable {
    let articleList: [ArticleDTO]
    let listSize, totalPage, totalElements: Int
    let isFirst, isLast: Bool
}

class ArticleDTO: Decodable {
    let articleId: Int
    let userInfo: UserInfoDTO
    let articleCategory: CategoryInfoDTO
    let title: String
    let contents: String
    let pictureUrl: String?
    let exerciseTag: String?
    let likes: Int
    let comments: Int
    let isLiked: Bool
    let createdAt: String
}

