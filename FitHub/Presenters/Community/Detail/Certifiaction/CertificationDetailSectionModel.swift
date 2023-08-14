//
//  CertificationDetailSectionModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import UIKit
import RxDataSources

enum CertificationDetailSectionModel {
    enum SectionItem {
        case detailInfo(info: CertificationDetailDTO)
        case comments(commentsInfo: CommentDTO)
    }
    
    case detailInfo(items: [Item])
    case comments(items: [Item])
    
    var items: [SectionItem] {
        switch self {
        case .detailInfo(items: let items): return items
        case .comments(items: let items): return items
        }
    }
}

extension CertificationDetailSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    init(original: CertificationDetailSectionModel, items: [Item]) {
        switch original {
        case .detailInfo(items: let items):
            self = .detailInfo(items: items)
        case .comments(items: let items):
            self = .comments(items: items)
        }
    }
}
