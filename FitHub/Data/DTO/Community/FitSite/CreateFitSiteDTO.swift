//
//  CreateFitSiteDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import Foundation

class CreateFitSiteDTO: Decodable {
    let articleId: Int
    let title: String
    let ownerId: Int
    let createdAt: String
}
