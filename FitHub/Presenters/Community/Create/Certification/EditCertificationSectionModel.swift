//
//  EditCertificationSectionModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/28.
//

import UIKit
import RxDataSources

enum EditCertificationSectionModel {
    enum SectionItem: Equatable {
        case image(image: UIImage?)
        case content(string: String)
        case hashtag(string: String)
        case sport(item: CategoryDTO)
    }
    
    case image(items: [Item])
    case content(items: [Item])
    case hashtag(items: [Item])
    case sport(items: [Item])
    
    var items: [SectionItem] {
        switch self {
        case .image(items: let items): return items
        case .content(items: let items): return items
        case .hashtag(items: let items): return items
        case .sport(items: let items): return items
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
        case .sport(items: let items):
            self = .sport(items: items)
        }
    }
}

