//
//  SearchTotalDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation

class SearchTotalDTO: Decodable {
    let articlePreview: FitSiteFeedDTO
    let recordPreview: CertificationFeedDTO
}
