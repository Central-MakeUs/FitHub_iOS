//
//  SearchTotalSectionModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/16.
//

import Foundation
import RxDataSources


enum SearchTotalSectionModel {
    enum SectionItem {
        case certification(record: CertificationDTO)
        case fitSite(article: ArticleDTO)
    }
    
    case certification(items: [Item])
    case fitSite(items: [Item])
    
    var items: [SectionItem] {
        switch self {
        case .certification(items: let items): return items
        case .fitSite(items: let items): return items
        }
    }
}

extension SearchTotalSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    init(original: SearchTotalSectionModel, items: [Item]) {
        switch original {
        case .certification(items: let items):
            self = .certification(items: items)
        case .fitSite(items: let items):
            self = .fitSite(items: items)
        }
    }
}
