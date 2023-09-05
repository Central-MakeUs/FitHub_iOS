//
//  EditCertifiactionViewModel.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/28.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateCertificationViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    var usecase: CreateCertificationUseCaseProtocol
    
    var imageSource = BehaviorSubject<UIImage?>(value: nil)
    
    var contentSource = BehaviorSubject<String?>(value: nil)
    
    var hashTagSource = BehaviorRelay<[String]>(value: [""])
    
    var selectedSportSource: BehaviorRelay<CategoryDTO?> = BehaviorRelay(value: nil)
    
    var addHashTagEnable = BehaviorRelay<Bool>(value: true)
    
    let completePublisher = PublishSubject<Bool>()
    
    struct Input {
        let completeTap: Observable<Void>
    }
    
    struct Output {
        let dataSource: Observable<[CreateCertificationSectionModel]>
        let completeEnable: Observable<Bool>
        let completePublisher: PublishSubject<Bool>
    }
    
    init(usecase: CreateCertificationUseCaseProtocol) {
        self.usecase = usecase
        Observable.combineLatest(imageSource,
                                 contentSource,
                                 hashTagSource,
                                 selectedSportSource)
        .map { CreateCertificationModel(profileImage: $0, content: $1, hashtags: $2, selectedSport: $3) }
        .subscribe(onNext: { [weak self] model in
            self?.usecase.certifiactionInfo = model
        })
        .disposed(by: disposeBag)
        
        hashTagSource
            .map { $0.count < 5 }
            .bind(to: self.addHashTagEnable)
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        let imageSourceSection = imageSource
            .map { [CreateCertificationSectionModel.image(items: [.image(image: $0)])]}
        
        let contentSection = contentSource
            .map {
                [CreateCertificationSectionModel.content(items: [.content(string: $0 ?? "")])]
            }
        
        let hashTagSection = hashTagSource
            .map { $0.map {
                CreateCertificationSectionModel.Item.hashtag(string: $0)
            }}
            .map { [CreateCertificationSectionModel.hashtag(items: $0)] }
        
        let sportSection = self.usecase.sports
            .map { $0.map {
                CreateCertificationSectionModel.Item.sport(item: $0)
            }}
            .map { [CreateCertificationSectionModel.sport(items: $0)] }
        
        let dataSource = Observable.combineLatest(imageSourceSection,
                                                  contentSection,
                                                  hashTagSection,
                                                  sportSection)
            .map { $0.0 + $0.1 + $0.2 + $0.3 }
        
        let completeEnable = Observable.combineLatest(imageSource,
                                                      selectedSportSource)
            .map { $0 != nil && $1 != nil }
        
        input.completeTap
            .subscribe(onNext: {
                LoadingIndicatorView.showLoading()
            })
            .disposed(by: disposeBag)
        
        input.completeTap
            .subscribe(onNext: {
                self.usecase.createCertification()
                    .subscribe(onSuccess: { _ in
                        LoadingIndicatorView.hideLoading()
                        self.completePublisher.onNext(true)
                    }, onFailure: { _ in
                        LoadingIndicatorView.hideLoading()
                        self.completePublisher.onNext(false)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
            
        return Output(dataSource: dataSource,
                      completeEnable: completeEnable,
                      completePublisher: completePublisher)
    }
    
    
    func addHashTag(_ hashTag: String) {
        var newHashTags = self.hashTagSource.value
        newHashTags.append(hashTag)
        self.hashTagSource.accept(newHashTags)
    }
    
    func changeContent(_ text: String) {
        self.contentSource.onNext(text)
    }
}
