//
//  reportUserDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import Foundation

struct ReportUserDTO: Decodable {
    let reportedAt: String
    let reportedUserId: Int
}
