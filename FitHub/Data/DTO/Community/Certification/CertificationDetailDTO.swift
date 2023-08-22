//
//  CertificationDetailDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import Foundation

class CertificationDetailDTO: Decodable {
    let recordId: Int
    let recordCategory: CategoryInfoDTO
    let loginUserProfileUrl: String
    let userInfo: UserInfoDTO
    let contents: String
    let pictureImage: String?
    let comments: Int
    let createdAt: String
    let likes: Int
    let isLiked: Bool
    let hashtags: HashTagsDTO
}

class HashTagsDTO: Decodable {
    let hashtags: [HashTagDTO]
    let size: Int
    class HashTagDTO: Decodable {
        let hashTagId: Int
        let name: String
    }

}
