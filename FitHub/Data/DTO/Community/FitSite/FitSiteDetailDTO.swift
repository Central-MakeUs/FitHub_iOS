//
//  FitSiteDetailDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import Foundation

class FitSiteDetailDTO: Decodable {
    let articleId: Int
    let articleCategory: CategoryInfoDTO
    let loginUserProfileUrl: String
    let userInfo: UserInfoDTO
    let title, contents: String
    let articlePictureList: ArticlePictureList
    let createdAt: String
    let likes, comments, scraps: Int
    let isLiked, isScraped: Bool
    let hashtags: HashTagsDTO
}

class ArticlePictureList: Decodable {
    let pictureList: [PictureList]
    let size: Int
}

class PictureList: Decodable {
    let pictureId: Int
    let pictureUrl: String
}
