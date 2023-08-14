//
//  CreateCertificationDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/31.
//

import Foundation

class CreateCertificationDTO: Decodable {
    let recordId: Int
    let ownerId: Int
    let createdAt: String
}
