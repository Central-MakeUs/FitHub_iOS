//
//  LevelInfoDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation

struct LevelInfoDTO: Decodable {
    let myLevelInfo: MyLevelInfo
    let fithubLevelInfo: FithubLevelInfo
}

struct FithubLevelInfo: Decodable {
    let expSummary, expDescription, comboSummary, comboDescription: String
    let fithubLevelList: [FithubLevelList]
}

struct FithubLevelList: Decodable {
    let levelIconUrl: String
    let level: Int
    let levelName: String
}

struct MyLevelInfo: Decodable {
    let levelIconUrl: String
    let level: Int
    let levelName, levelSummary, levelDescription: String
}
