//
//  AlarmListDTO.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/23.
//

import Foundation

struct AlarmListDTO: Decodable {
    let alarmList: [AlarmDTO]
    let listSize: Int
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool
}

struct AlarmDTO: Decodable {
    let alarmType: String
    let alarmBody: String
    let targetId: Int
    let alarmId: Int
    var isConfirmed: Bool
    let createdAt: String
}
