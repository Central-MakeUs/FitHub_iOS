//
//  MyPageUseCase.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/18.
//

import Foundation
import RxSwift

protocol MyPageUseCaseProtocol {
    func fetchMyPage() -> Single<MyPageDTO>
    func changeProfile(imageData: Data)-> Single<ChangeProfileDTO>
    func setDefaultProfile()-> Single<Bool>
    func changeMainExercise(categoryId: Int)-> Single<Bool>
    func fetchCategory() -> Single<[CategoryDTO]>
    func getCurrentMainExercise()-> Single<CurrentExerciseDTO>
}

final class MyPageUseCase: MyPageUseCaseProtocol {
    private let mypageRepository: MyPageRepositoryInterface
    
    init(mypageRepository: MyPageRepositoryInterface) {
        self.mypageRepository = mypageRepository
    }
    
    func fetchMyPage() -> Single<MyPageDTO> {
        return mypageRepository.fetchMyPage()
    }
    
    func changeProfile(imageData: Data)-> Single<ChangeProfileDTO> {
        return mypageRepository.changeProfile(imageData: imageData)
    }
    
    func setDefaultProfile()-> Single<Bool> {
        return mypageRepository.setDefaultProfile()
    }
    
    func changeMainExercise(categoryId: Int)-> Single<Bool> {
        return mypageRepository.changeMainExercise(categoryId: categoryId)
    }
    
    func fetchCategory() -> Single<[CategoryDTO]> {
        return mypageRepository.fetchCategory()
    }
    
    func getCurrentMainExercise()-> Single<CurrentExerciseDTO> {
        return mypageRepository.getCurrentMainExercise()
    }
}
