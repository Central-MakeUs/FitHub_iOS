//
//  EditCertificationViewModel.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class EditCertificationViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    private let recordId: Int
    
    private let usecase: EditCertificationUseCaseProtocol
    
    private var oldCertification = CreateCertificationModel()
    
    private var newCertification = CreateCertificationModel()

    var imageSource = BehaviorSubject<UIImage?>(value: nil)
    
    var contentSource = BehaviorSubject<String?>(value: nil)
    
    var hashTagSource = BehaviorRelay<[String]>(value: [""])
    
    let sportSection = BehaviorSubject<[CategoryDTO]>(value: [])
    
    var selectedSportSource: BehaviorRelay<CategoryDTO?> = BehaviorRelay(value: nil)
    
    var addHashTagEnable = BehaviorRelay<Bool>(value: true)
    
    let completePublisher = PublishSubject<Bool>()
    
    var remainImageUrl: String?
    
    struct Input {
        let completeTap: Observable<Void>
    }
    
    struct Output {
        let dataSource: Observable<[CreateCertificationSectionModel]>
        let completeEnable: Observable<Bool>
        let completePublisher: PublishSubject<Bool>
    }
    
    init(usecase: EditCertificationUseCaseProtocol, info: CertificationDetailDTO) {
        self.recordId = info.recordId
        self.usecase = usecase
        
        var hashTags = info.hashtags.hashtags.map { $0.name }
        if !hashTags.isEmpty { hashTags[0] = "" }

        oldCertification.hashtags = hashTags
        hashTagSource.accept(hashTags)
        
        oldCertification.content = info.contents
        contentSource.onNext(info.contents)
        
        self.remainImageUrl = info.pictureImage
        convertImage(imageString: info.pictureImage)
        
        usecase.fetchCategory()
            .subscribe(onSuccess: { [weak self] categories in
                self?.sportSection.onNext(categories)
                if let idx = categories.firstIndex(where: { $0.id == info.recordCategory.categoryId }) {
                    self?.selectedSportSource.accept(categories[idx])
                }
            })
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(imageSource,
                                 contentSource,
                                 hashTagSource,
                                 selectedSportSource)
        .map { CreateCertificationModel(profileImage: $0, content: $1, hashtags: $2, selectedSport: $3) }
        .subscribe(onNext: { [weak self] model in
            self?.newCertification = model
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
        
        
        let sportSection = self.sportSection
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
            .bind(onNext: {
                LoadingIndicatorView.showLoading()
            })
            .disposed(by: disposeBag)
        
        input.completeTap
            .subscribe(onNext: {
                self.usecase.updateCertification(recordId: self.recordId,
                                                 certificationInfo: self.newCertification,
                                                 remainImageUrl: self.remainImageUrl)
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

extension EditCertificationViewModel {
    func convertImage(imageString: String?) {
        guard let url = URL(string: imageString ?? "") else { return }
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let data):
                let image: UIImage = data.image
                self?.imageSource.onNext(image)
            case .failure(let error):
                print(error)
            }
        }
    }
}
