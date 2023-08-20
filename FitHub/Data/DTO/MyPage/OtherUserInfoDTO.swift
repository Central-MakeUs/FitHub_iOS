//
//  OtherUserInfoDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import Foundation

struct OtherUserInfoDTO: Decodable {
    let nickname: String
    let mainExerciseInfo: MyExerciseItemDTO
    let profileUrl: String?
}
