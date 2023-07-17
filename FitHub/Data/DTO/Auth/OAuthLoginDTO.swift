//
//  OAuthLoginDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/17.
//

import Foundation

struct OAuthLoginDTO: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String?
    let result: OAuthLoginResult?
}

class OAuthLoginResult: Codable {
    let isLogin: Bool
    let jwt: String
}
