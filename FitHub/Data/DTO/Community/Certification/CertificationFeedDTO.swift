//
//  CertificationFeedDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation

class CertificationFeedDTO: Decodable {
    let recordList: [CertificationDTO]
    let listSize: Int
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool
}

class CertificationDTO: Decodable {
    let recordId: Int
    let pictureUrl: String?
    let likes: Int
    let createdAt: String
    let isLiked: Bool
}

