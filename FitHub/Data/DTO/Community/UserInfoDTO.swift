//
//  UserInfoDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import Foundation

class UserInfoDTO: Decodable {
    let ownerId: Int
    let nickname: String
    let isDefaultProfile: Bool
    let mainExerciseInfo: ExerciseInfoDTO
    let profileUrl: String?
}

class ExerciseInfoDTO: Decodable {
    let category: String
    let level: Int
    let gradeName: String
}
