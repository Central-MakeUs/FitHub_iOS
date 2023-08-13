//
//  ReportCommentDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import Foundation

struct ReportCommentDTO: Decodable {
    let reportedCommentId: Int
    let reportedAt: String
}
