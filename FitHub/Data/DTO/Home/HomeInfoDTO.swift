//
//  HomeInfoDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/02.
//

import Foundation

struct HomeInfoDTO: Decodable {
    let userInfo: HomeUserInfoDTO
    let bestRecorderList: [BestRecorderDTO]
    let bestStandardDate: String
}
