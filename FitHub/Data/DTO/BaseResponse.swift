//
//  BaseResponse.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/22.
//

import Foundation

struct BaseResponse<Result: Decodable>: Decodable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: Result?
}

struct BaseArrayResponse<Result: Decodable>: Decodable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [Result]?
}
