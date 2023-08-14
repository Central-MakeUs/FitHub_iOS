//
//  LikeCertificationDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation

struct LikeCertificationDTO: Decodable {
    let recordId: Int
    let newLikes: Int
    let isLiked: Bool
}
