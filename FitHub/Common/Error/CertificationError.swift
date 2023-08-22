//
//  CertificationError.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation

enum CertificationError: Error {
    case invalidURL
    case serverError
    case invalidCertification
    case otherError
}
