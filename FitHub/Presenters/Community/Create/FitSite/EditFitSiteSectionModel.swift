//
//  EditFitSiteSectionModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/11.
//

import UIKit
import RxDataSources

enum EditFitSiteSectionModel {
    enum SectionItem: Equatable {
        case title(string: String)
        case content(string: String)
        case image(image: UIImage?)
        case hashtag(string: String)
        case sport(item: CategoryDTO)
    }
    
    case title(items: [Item])
    case content(items: [Item])
    case hashtag(items: [Item])
    case image(items: [Item])
    case sport(items: [Item])
    
    var items: [SectionItem] {
        switch self {
        case .title(items: let items): return items
        case .content(items: let items): return items
        case .image(items: let items): return items
        case .hashtag(items: let items): return items
        case .sport(items: let items): return items
        }
    }
}

extension EditFitSiteSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    init(original: EditFitSiteSectionModel, items: [Item]) {
        switch original {
        case .title(items: let items):
            self = .title(items: items)
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
