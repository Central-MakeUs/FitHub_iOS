//
//  EditFitSiteModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/11.
//

import UIKit

struct EditFitSiteModel {
    var title: String?
    var content: String?
    var images: [UIImage?] = []
    var hashtags: [String] = []
    var selectedSport: CategoryDTO?
}
