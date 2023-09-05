//
//  EditFitSiteViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/11.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateFitSiteViewModel : ViewModelType {
    var disposeBag = DisposeBag()
    
    var usecase: CreateFitSiteUseCaseProtocol
    
    var imageSource = BehaviorRelay<[UIImage?]>(value: [nil])
    
    var contentSource = BehaviorSubject<String>(value: "")
    
    var titleSource = BehaviorSubject<String>(value: "")
    
    var hashTagSource = BehaviorRelay<[String]>(value: [""])
    
    var selectedSportSource: BehaviorRelay<CategoryDTO?> = BehaviorRelay(value: nil)
    
    var addHashTagEnable = BehaviorRelay<Bool>(value: true)
    
    let completePublisher = PublishSubject<Bool>()
    
    var fitSiteInfo = EditFitSiteModel()
    
    let sports = BehaviorSubject<[CategoryDTO]>(value: [])
    
    struct Input {
        let completeTap: Observable<Void>
    }
    
    struct Output {
        let dataSource: Observable<[EditFitSiteSectionModel]>
        let completeEnable: Observable<Bool>
        let completePublisher: PublishSubject<Bool>
    }
    
    init(usecase: CreateFitSiteUseCaseProtocol) {
        self.usecase = usecase
        
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] categories in
                self?.sports.onNext(categories)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(titleSource,
                                 contentSource,
                                 imageSource,
                                 hashTagSource,
                                 selectedSportSource)
        .map { EditFitSiteModel(title: $0.0, content: $0.1, images: $0.2, hashtags: $0.3, selectedSport: $0.4)}
        .subscribe(onNext: { [weak self] model in
            self?.fitSiteInfo = model
        })
        .disposed(by: disposeBag)
        
        hashTagSource
            .map { $0.count < 5 }
            .bind(to: self.addHashTagEnable)
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        let titleSection = titleSource
            .map { [EditFitSiteSectionModel.title(items: [.title(string: $0)])]}
        
        let contentSection = contentSource
            .map {
                [EditFitSiteSectionModel.content(items: [.content(string: $0 ?? "")])]
            }
        
        let imageSourceSection = imageSource
            .map { $0.map {
                EditFitSiteSectionModel.Item.image(image: $0)
            }}
            .map { [EditFitSiteSectionModel.image(items: $0)] }
            
        
        let hashTagSection = hashTagSource
            .map { $0.map {
                EditFitSiteSectionModel.Item.hashtag(string: $0)
            }}
            .map { [EditFitSiteSectionModel.hashtag(items: $0)] }
        
        let sportSection = sports
            .map { $0.map {
                EditFitSiteSectionModel.Item.sport(item: $0)
            }}
            .map { [EditFitSiteSectionModel.sport(items: $0)] }
        
        let dataSource = Observable.combineLatest(titleSection,
                                                  contentSection,
                                                  imageSourceSection,
                                                  hashTagSection,
                                                  sportSection)
            .map { $0.0 + $0.1 + $0.2 + $0.3 + $0.4 }
        
        let completeEnable = Observable.combineLatest(titleSource,
                                                      contentSource,
                                                      selectedSportSource)
            .map { !$0.0.isEmpty && !$0.1.isEmpty && $0.2 != nil }
        
        input.completeTap
            .bind(onNext: {
                LoadingIndicatorView.showLoading()
            })
            .disposed(by: disposeBag)
            
        input.completeTap
            .withLatestFrom(self.selectedSportSource)
            .compactMap { $0?.id }
            .flatMap {
                self.usecase.createArticle(categoryId: $0,
                                           feedInfo: self.fitSiteInfo).asObservable()
                    .catchAndReturn(false)
            }
            .subscribe(onNext: { [weak self] isSuccess in
                self?.completePublisher.onNext(isSuccess)
                LoadingIndicatorView.hideLoading()
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
