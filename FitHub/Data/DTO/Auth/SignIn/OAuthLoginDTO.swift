//
//  OAuthLoginDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/17.
//

import Foundation

class OAuthLoginDTO: Codable {
    let isLogin: Bool
    let accessToken: String
    let userId: Int
    let userName: String?
}
