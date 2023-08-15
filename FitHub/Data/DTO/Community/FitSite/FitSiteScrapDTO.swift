//
//  FitSiteScrapDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation

struct FitSiteScrapDTO: Decodable {
    let articleId: Int
    let articleSaves: Int
    let isSaved: Bool
}
