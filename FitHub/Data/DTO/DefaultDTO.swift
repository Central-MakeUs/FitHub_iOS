//
//  DTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/12.
//

import Foundation

class DefaultResponseDTO: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String?
    let result: [String]?
}
