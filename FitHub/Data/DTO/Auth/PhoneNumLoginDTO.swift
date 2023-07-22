//
//  PhoneNumLoginDTO.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/22.
//

import Foundation

struct PhoneNumLoginDTO: Codable {
    let targetPhoneNum: String
    let password: String
}
