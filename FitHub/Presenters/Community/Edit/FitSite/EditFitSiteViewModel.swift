//
//  FitSiteViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/21.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class EditFitSiteViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    var usecase: EditFitSiteUseCaseProtocol
    
    private let articleId: Int
    
    var imageSource = BehaviorRelay<[UIImage?]>(value: [nil])
    
    var contentSource = BehaviorSubject<String>(value: "")
    
    var titleSource = BehaviorSubject<String>(value: "")
    
    var hashTagSource = BehaviorRelay<[String]>(value: [""])
    
    var selectedSportSource: BehaviorRelay<CategoryDTO?> = BehaviorRelay(value: nil)
    
    var addHashTagEnable = BehaviorRelay<Bool>(value: true)
    
    let completePublisher = PublishSubject<Bool>()
    
    let sports = BehaviorSubject<[CategoryDTO]>(value: [])
    
    var oldFitsiteInfo = EditFitSiteModel()
    var newFitSiteInfo = EditFitSiteModel()
    
    var remainImageList: [String]?
    
    struct Input {
        let completeTap: Observable<Void>
    }
    
    struct Output {
        let dataSource: Observable<[EditFitSiteSectionModel]>
        let completeEnable: Observable<Bool>
        let completePublisher: PublishSubject<Bool>
    }
    
    init(usecase: EditFitSiteUseCaseProtocol,
         info: FitSiteDetailDTO) {
        self.usecase = usecase
        self.articleId = info.articleId
        self.remainImageList = info.articlePictureList.pictureList.map { $0.pictureUrl }
        print(info.hashtags.hashtags.map { $0.name })
        var hashTags = info.hashtags.hashtags.map { $0.name }
        if !hashTags.isEmpty { hashTags[0] = "" }
        
        oldFitsiteInfo.hashtags = hashTags
        hashTagSource.accept(hashTags)
        
        oldFitsiteInfo.title = info.title
        titleSource.onNext(info.title)
        
        oldFitsiteInfo.content = info.contents
        contentSource.onNext(info.contents)
        
        convertImages(imageStringArray: self.remainImageList)
        
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] categories in
                self?.sports.onNext(categories)
                if let idx = categories.firstIndex(where: { $0.id == info.articleCategory.categoryId }) {
                    self?.selectedSportSource.accept(categories[idx])
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(titleSource,
                                 contentSource,
                                 imageSource,
                                 hashTagSource,
                                 selectedSportSource)
        .map { EditFitSiteModel(title: $0.0, content: $0.1, images: $0.2, hashtags: $0.3, selectedSport: $0.4)}
        .subscribe(onNext: { [weak self] model in
            self?.newFitSiteInfo = model
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
                [EditFitSiteSectionModel.content(items: [.content(string: $0)])]
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
            .flatMap { self.usecase.updateArticle(articleId: self.articleId,
                                                  feedInfo: self.newFitSiteInfo,
                                                  remainImageList: self.remainImageList ?? []).asObservable()
                    .catchAndReturn(false)
            }
            .subscribe(onNext: { [weak self] isSuccess in
                self?.completePublisher.onNext(isSuccess)
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

extension EditFitSiteViewModel {
    func convertImages(imageStringArray: [String]?) {
        guard let imageStringArray else { return }
        var images: [UIImage] = []
        for imageString in imageStringArray {
            guard let url = URL(string: imageString) else { return }
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let data):
                    let image: UIImage = data.image
                    images.append(image)
                case .failure(let error):
                    print(error)
                }
            }
        }
        self.imageSource.accept( [nil] + images)
    }
}
