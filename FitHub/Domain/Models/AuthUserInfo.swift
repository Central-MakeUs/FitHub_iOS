//
//  RegistUserInfo.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/30.
//

import UIKit

struct AuthUserInfo {
    var phoneNumber: String?
    var dateOfBirth: String?
    var sexNumber: String?
    var password: String?
    var name: String?
    var telecom: TelecomProviderType?
    var nickName: String?
    var profileImage: UIImage?
    var marketingAgree = false
    var preferExercise: [CategoryDTO] = []
}
