//
//  MyPageDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/18.
//

import Foundation

class MyPageDTO: Decodable {
    let myInfo: MyInfoDTO
    let myExerciseList: [MyExerciseItemDTO]
}

class MyExerciseItemDTO: Decodable {
    let category: String
    let level, exp, maxExp: Int
    let gradeName: String
}

class MyInfoDTO: Decodable {
    let ownerId: Int
    let nickname: String
    let isDefaultProfile: Bool
    let mainExerciseInfo: MainExerciseInfoDTO
    let profileUrl: String?
}

class MainExerciseInfoDTO: Decodable {
    let category: String
    let level: Int
    let gradeName: String
}
