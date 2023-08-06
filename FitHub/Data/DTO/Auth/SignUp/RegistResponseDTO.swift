//
//  RegistResponseDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/26.
//

import Foundation

final class RegistResponseDTO: Decodable {
    let userId: Int
    let nickname: String
    let accessToken: String?
}
