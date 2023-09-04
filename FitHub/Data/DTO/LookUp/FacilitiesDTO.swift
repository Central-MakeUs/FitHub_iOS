//
//  FacilitiesDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/27.
//

import Foundation

struct FacilitiesDTO: Decodable {
    let facilitiesList: [FacilityDTO]
    let size: Int
    let userX: String
    let userY: String
}

struct FacilitiesKeywordDTO: Decodable {
    let facilitiesList: [FacilityDTO]
    let size: Int
    let userX: String
    let userY: String
}

class FacilityDTO: NSObject, Decodable {
    let name: String
    let address: String
    let roadAddress: String
    let imageUrl: String?
    let phoneNumber: String?
    let category: String
    let categoryId: Int
    let x: String
    let y: String
    let dist: String
}
