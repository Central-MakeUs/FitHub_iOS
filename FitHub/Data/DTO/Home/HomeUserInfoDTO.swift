//
//  HomeUserInfoDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/02.
//

import Foundation

struct HomeUserInfoDTO: Decodable {
    let userNickname: String
    let category: String
    let exp: Int
    let maxExp: Int
    let monthRecordCount: Int
    let contiguousRecordCount: Int
    let gradeImageUrl: String
    let gradeName: String
}
