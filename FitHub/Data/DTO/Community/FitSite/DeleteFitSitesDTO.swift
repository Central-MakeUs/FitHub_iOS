//
//  DeleteFitSitesDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import Foundation

struct DeleteFitSitesDTO: Decodable {
    let deletedArticleList: [DeleteFitSiteDTO]
    let size: Int
}

struct DeleteFitSiteDTO: Decodable {
    let articleId: Int
    let deletedAt: String
}
