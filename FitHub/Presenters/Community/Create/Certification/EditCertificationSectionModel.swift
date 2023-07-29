//
//  EditCertificationSectionModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/28.
//

import Foundation
import RxDataSources

struct CustomData {
    var title: String
}

enum EditCertificationSectionModel {
    enum SectionItem: Equatable {
        case image(image: String?)
        case content(string: String)
        case hashtag(string: String)
    }
    
    case image(items: [Item])
    case content(items: [Item])
    case hashtag(items: [Item])
    
    var items: [SectionItem] {
        switch self {
        case .image(items: let items): return items
        case .content(items: let items): return items
        case .hashtag(items: let items): return items
        }
    }
}

extension EditCertificationSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    init(original: EditCertificationSectionModel, items: [Item]) {
        switch original {
        case .content(items: let items):
            self = .content(items: items)
        case .hashtag:
            self = .hashtag(items: items)
        case .image:
            self = .image(items: items)
        }
    }
}

