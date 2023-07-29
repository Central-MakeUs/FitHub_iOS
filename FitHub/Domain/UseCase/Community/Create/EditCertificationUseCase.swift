//
//  EditCertificationUseCase.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import UIKit
import RxSwift

protocol EditCertificationUseCaseProtocol {
    var profileImage: UIImage { get set }
    var hashtags: [String] { get set }
    var content: String { get set }
    var selectedCategoryId: Int { get set }
}

final class EditCertificationUseCase: EditCertificationUseCaseProtocol {
    var profileImage = UIImage()
    
    var hashtags = [String]()
    
    var content = String()
    
    var selectedCategoryId = Int()
}
