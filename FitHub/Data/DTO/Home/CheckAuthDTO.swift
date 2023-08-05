//
//  CheckAuthDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/05.
//

import Foundation

struct CheckAuthDTO: Decodable {
    let userId: Int?
    let accessToken: String?
}
