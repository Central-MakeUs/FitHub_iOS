//
//  NotificationName+.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/03.
//

import Foundation

extension Notification.Name {
    static let dismissStandardAlert = Notification.Name("dismissStandardAlert")
    static let presentAlert = Notification.Name("presentAlert")
    static let tapChangeMainExercise = Notification.Name("tapChangeMainExercise")
    static let tapLookupWithCategory = Notification.Name("tapLookupWithCategory")
    static let tapCertificationAtHome = Notification.Name("tapCertificationAtHome")
    static let didRecieveAlert = Notification.Name("didRecieveAlert")
}
