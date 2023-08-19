//
//  PrivacyInfoDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/19.
//

import Foundation

struct PrivacyInfoDTO: Decodable {
    let name: String
    let email: String?
    let phoneNum: String?
    let isSocial: Bool
}
