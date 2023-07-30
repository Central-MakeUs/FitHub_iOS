//
//  EditCertificationModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/31.
//

import UIKit

struct EditCertificationModel {
    var profileImage: UIImage?
    var content: String?
    var hashtags: [String] = []
    var selectedSport: CategoryDTO?
}
