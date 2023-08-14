//
//  DeleteCertificationDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation

struct DeleteCertificationDTO: Decodable {
    let recordId: Int
    let deletedAt: String
}
