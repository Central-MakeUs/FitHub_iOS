//
//  BookMarkDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation

struct BookMarkDTO: Decodable {
    let articleList: [ArticleDTO]
    let listSize, totalPage, totalElements: Int
    let isFirst, isLast: Bool
}
