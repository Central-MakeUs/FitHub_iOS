//
//  AuthError.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import Foundation

enum AuthError: Error {
    case invalidURL
    case serverError
    case oauthFailed
    case unknownUser
    case passwordFaild
}
