//
//  MyPageRepository.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/18.
//

import Foundation
import RxSwift

protocol MyPageRepositoryInterface {
    func fetchMyPage() -> Single<MyPageDTO>
    func changeProfile(imageData: Data)-> Single<ChangeProfileDTO>
    func setDefaultProfile()-> Single<Bool>
    func changeMainExercise(categoryId: Int)-> Single<Bool>
    func fetchCategory() -> Single<[CategoryDTO]>
    func getCurrentMainExercise()-> Single<CurrentExerciseDTO>
    func fetchPrivacyInfo() -> Single<PrivacyInfoDTO>
    func quitAuth() -> Single<Bool>
    func checkPassword(password: String) -> Single<Bool>
    func changePassword(newPassword: String) -> Single<Bool>
    func fetchCertificationFeed(categoryId: Int, page: Int) -> Single<CertificationFeedDTO>
    func fetchFitSiteFeed(categoryId: Int, page: Int) -> Single<FitSiteFeedDTO>
    func fetchOtherProfileInfo(userId: Int) -> Single<BaseResponse<OtherUserInfoDTO>>
    func fetchOtherUserArticle(userId: Int, categoryId: Int, page: Int) -> Single<FitSiteFeedDTO>
    func logout() -> Single<Bool>
}

final class MyPageRepository: MyPageRepositoryInterface {
    private let service: UserService
    
    init(service: UserService) {
        self.service = service
    }
    
    func fetchMyPage() -> Single<MyPageDTO> {
        return service.fetchMyPage()
    }
    
    func changeProfile(imageData: Data)-> Single<ChangeProfileDTO> {
        return service.changeProfile(imageData: imageData)
    }
    
    func setDefaultProfile()-> Single<Bool> {
        return service.setDefaultProfile()
    }
    
    func changeMainExercise(categoryId: Int)-> Single<Bool> {
        return service.changeMainExercise(categoryId: categoryId)
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return service.fetchCategory()
    }
    
    func getCurrentMainExercise()-> Single<CurrentExerciseDTO> {
        return service.getCurrentMainExercise()
    }
    
    func fetchPrivacyInfo() -> Single<PrivacyInfoDTO> {
        return service.fetchPrivacyInfo()
    }
    
    func quitAuth() -> Single<Bool> {
        return service.quitAuth()
    }
    
    func checkPassword(password: String) -> Single<Bool> {
        return service.checkPassword(password: password)
    }
    
    func changePassword(newPassword: String) -> Single<Bool> {
        return service.changePassword(newPassword: newPassword)
    }
    
    func fetchCertificationFeed(categoryId: Int, page: Int) -> Single<CertificationFeedDTO> {
        return service.fetchCertificationFeed(categoryId: categoryId, page: page)
    }
    
    func fetchFitSiteFeed(categoryId: Int, page: Int) -> Single<FitSiteFeedDTO> {
        return service.fetchFitSiteFeed(categoryId: categoryId, page: page)
    }
    
    func fetchOtherProfileInfo(userId: Int) -> Single<BaseResponse<OtherUserInfoDTO>> {
        return service.fetchOtherProfileInfo(userId: userId)
    }
    
    func fetchOtherUserArticle(userId: Int, categoryId: Int, page: Int) -> Single<FitSiteFeedDTO> {
        return service.fetchOtherUserArticle(userId: userId, categoryId: categoryId, page: page)
    }
    
    func logout() -> Single<Bool> {
        return service.logout()
    }
}
