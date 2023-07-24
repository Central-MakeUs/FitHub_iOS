//
//  CategoryDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/24.
//

import Foundation

struct CategoryDTO: Decodable {
    let createdAt: String?
    let updatedAt: String?
    let imageUrl: String?
    let name: String
    let id: Int
}
