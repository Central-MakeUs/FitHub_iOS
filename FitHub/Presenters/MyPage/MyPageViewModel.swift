//
//  MyPageViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/18.
//

import UIKit
import RxSwift
import RxCocoa

final class MyPageViewModel {
    private let disposeBag = DisposeBag()
    
    private let usecase: MyPageUseCaseProtocol
    
    init(usecase: MyPageUseCaseProtocol) {
        self.usecase = usecase
        
        Observable.combineLatest(currentCategoryId, newCategoryId)
            .map { $0 != $1 }
            .bind(to: changeButtonEnable)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Input
    func deleteProfileImage() {
        usecase.setDefaultProfile()
            .subscribe(onSuccess: { [weak self] _ in
                self?.profileImageChange.onNext(nil)
            }, onFailure: { [weak self] error in
                self?.errorHandler.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    func changeProfileImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: .leastNormalMagnitude) else { return }
        usecase.changeProfile(imageData: imageData)
            .subscribe(onSuccess: { [weak self] newImage in
                self?.profileImageChange.onNext(newImage)
            }, onFailure: { [weak self] error in
                self?.errorHandler.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    func viewWillAppear() {
        usecase.fetchMyPage()
            .subscribe(onSuccess: { [weak self] item in
                self?.myPageInfo.onNext(item)
            })
            .disposed(by: disposeBag)
    }
    
    func getCurrentMainExercise() {
        usecase.getCurrentMainExercise()
            .subscribe(onSuccess: { [weak self] currentCategory in
                self?.currentCategoryId.accept(currentCategory.currentExerciseCategory)
                self?.newCategoryId.accept(currentCategory.currentExerciseCategory)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchCategory() {
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] categories in
                self?.categories.onNext(categories)
            })
            .disposed(by: disposeBag)
    }
    
    func changeMainExercise()-> Single<Bool> {
        guard let newCategoryId = newCategoryId.value else { return Single.just(false) }
        return usecase.changeMainExercise(categoryId: newCategoryId)
    }
    
    // MARK: - Output
    let errorHandler = PublishSubject<Error>()
    let myPageInfo = PublishSubject<MyPageDTO>()
    let profileImageChange = PublishSubject<ChangeProfileDTO?>()
    
    let categories = PublishSubject<[CategoryDTO]>()
    let currentCategoryId = BehaviorRelay<Int?>(value: nil)
    let newCategoryId = BehaviorRelay<Int?>(value: nil)
    
    let changeButtonEnable = BehaviorSubject<Bool>(value: false)
}
