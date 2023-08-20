//
//  BestRecorderListDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/02.
//

import Foundation

struct BestRecorderDTO: Decodable {
    let id: Int
    let ranking: Int
    let rankingStatus: String
    let recorderNickName: String
    let category: String
    let level: Int
    let profileUrl: String
    let recordCount: Int
    let gradeName: String
}
