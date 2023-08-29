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

struct FacilityDTO: Decodable {
    let name: String
    let address: String
    let roadAddress: String
    let imageUrl: String?
    let phoneNumber: String?
    let category: String
    let x: String
    let y: String
    let dist: String
}
