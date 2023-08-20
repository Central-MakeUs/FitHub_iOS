//
//  CertificationDeleteRecordsDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import Foundation

struct CertificationDeleteRecordsDTO: Decodable {
    let deletedRecordList: [CertificationDeleteRecordDTO]
}

struct CertificationDeleteRecordDTO: Decodable {
    let recordId: Int
    let deletedAt: String
}
