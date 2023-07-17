//
//  NickName.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/17.
//

import Foundation

class NickNameDTO: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String?
    let result: String?
}
