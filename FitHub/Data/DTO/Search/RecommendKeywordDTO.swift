//
//  RecommendKeywordDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation

struct RecommendKeywordDTO: Decodable {
    let keywordList: [String]
    let size: Int
}
