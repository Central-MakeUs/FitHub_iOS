//
//  FitSiteDetailCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/14.
//

import UIKit
import RxSwift
import RxCocoa

protocol FitSiteDetailCellDelegate: AnyObject {
    func toggleLike(articleId: Int, completion: @escaping (LikeFitSiteDTO)->Void)
    func toggleScrap(articleId: Int, completion: @escaping ( FitSiteScrapDTO)->Void)
    func didClickUserProfile(ownerId: Int)
    func didClickContentImage(image: PictureList)
}

final class FitSiteDetailCell: UICollectionViewCell {
    static let identifier = "FitSiteDetailCell"
    
    private let disposeBag = DisposeBag()
    weak var delegate: FitSiteDetailCellDelegate?
    
    private let profileImageView = UIImageView(image: UIImage(named: "DefaultProfile")).then {
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "사용자명"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyMedium02)
    }
    
    private let sportLabel = PaddingLabel(padding: .init(top: 2, left: 4, bottom: 2, right: 4)).then {
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub02
        $0.layer.cornerRadius = 2
        $0.text = "운동명"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
    }
    
    private let gradeLabel = PaddingLabel(padding: .init(top: 2, left: 4, bottom: 2, right: 4)).then {
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub02
        $0.layer.cornerRadius = 2
        $0.text = "Lv100.코딩지옥"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
    }
    
    private let timeLabel = UILabel().then {
        $0.text = "-분 전"
        $0.textColor = .iconEnabled
        $0.font = .pretendard(.bodySmall01)
    }
    
    private lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.backgroundColor = .bgDefault
        $0.register(SimpleImageCell.self, forCellWithReuseIdentifier: SimpleImageCell.identifier)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "제목"
        $0.textColor = .textDefault
        $0.font = .pretendard(.titleMedium)
    }
    
    private let contentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .pretendard(.labelLarge)
        $0.textColor = .textDefault
        $0.text = "내용"
    }
    
    private let hashTagLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "#해시태그"
        $0.font = .pretendard(.labelLarge)
        $0.textColor = .secondary
    }
    
    let likeButton = UIButton(type: .system).then {
        var configure = UIButton.Configuration.plain()
        configure.image = UIImage(named: "ic_heart_default")?.withTintColor(.textSub02)
        configure.title = "-"
        configure.imagePlacement = .leading
        configure.imagePadding = 4
        configure.baseForegroundColor = .textSub02
        configure.attributedTitle?.font = .pretendard(.bodySmall01)
        configure.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        $0.configuration = configure
    }
    
    let commentButton = UIButton().then {
        var configure = UIButton.Configuration.plain()
        configure.image = UIImage(named: "ic_community_default")
        configure.title = "-"
        configure.imagePlacement = .leading
        configure.imagePadding = 4
        configure.baseForegroundColor = .textSub02
        configure.attributedTitle?.font = .pretendard(.bodySmall01)
        configure.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        $0.configuration = configure
    }
    
    private let bookmarkButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    let dividerView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews()
        self.layout()
        setUpBidning()
        
        self.backgroundColor = .bgDefault
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: FitSiteDetailDTO) {
        self.titleLabel.text = item.title
        self.nameLabel.text = item.userInfo.nickname
        self.sportLabel.text = item.articleCategory.name
        let grade = "Lv.\(item.userInfo.mainExerciseInfo.level) \(item.userInfo.mainExerciseInfo.gradeName)"
        self.gradeLabel.text = grade
        self.gradeLabel.highlightGradeName(grade: item.userInfo.mainExerciseInfo.gradeName, highlightText: grade)
        self.timeLabel.text = item.createdAt
        self.contentLabel.text = item.contents
        self.hashTagLabel.text = item.hashtags.hashtags.map { "#" + $0.name }.joined(separator: " ")
        self.profileImageView.kf.setImage(with: URL(string: item.userInfo.profileUrl ?? ""))
        
        self.configureBookmark(isScraped: item.isScraped)
        self.configureLikeButton(isLiked: item.isLiked)
        
        likeButton.configuration?.title = "\(item.likes)"
        commentButton.configuration?.title = "\(item.comments)"
        self.likeButton.configuration?.attributedTitle?.font = .pretendard(.bodySmall01)
        self.commentButton.configuration?.attributedTitle?.font = .pretendard(.bodySmall01)
        configureImageList(pictureList: item.articlePictureList.pictureList)
        
        self.likeButton.tag = item.articleId
        self.profileImageView.tag = item.userInfo.ownerId
    }
    
    func configureLikeButton(isLiked: Bool) {
        let image = isLiked ? UIImage(named: "ic_heart_pressed")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "ic_heart_default")?.withTintColor(.textSub02)
        let color: UIColor = isLiked ? .error : .textSub02
        
        self.likeButton.configuration?.baseForegroundColor = color
        self.likeButton.configuration?.image = image
    }
    
    func configureBookmark(isScraped: Bool) {
        // MARK: - 북마크 이미지 분기하기
        let image = isScraped ? UIImage(named: "ic_bookmark_fill") : UIImage(named: "BookMark")
        bookmarkButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func configureImageList(pictureList: [PictureList]) {
        updateImageListViewLayout(isEmpty: pictureList.isEmpty)
        imageCollectionView.delegate = nil
        imageCollectionView.dataSource = nil
        
        Observable.of(pictureList)
            .bind(to: self.imageCollectionView.rx.items(cellIdentifier: SimpleImageCell.identifier, cellType: SimpleImageCell.self)) { index, item, cell in
                cell.configureCell(item: item)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateImageListViewLayout(isEmpty: Bool) {
        if isEmpty {
            imageCollectionView.snp.makeConstraints {
                $0.height.equalTo(0)
                $0.top.equalTo(contentLabel.snp.bottom).offset(0)
            }
        } else {
            imageCollectionView.snp.makeConstraints {
                $0.height.equalTo(100)
                $0.top.equalTo(contentLabel.snp.bottom).offset(15)
            }
        }
    }
    
    private func setUpBidning() {
        likeButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.toggleLike(articleId: self.likeButton.tag) { item in
                    self.configureLikeButton(isLiked: item.isLiked)
                    self.likeButton.configuration?.title = "\(item.articleLikes)"
                    self.likeButton.configuration?.attributedTitle?.font = .pretendard(.bodySmall01)
                }
            })
            .disposed(by: disposeBag)
        
        bookmarkButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.toggleScrap(articleId: self.likeButton.tag) { item in
                    self.configureBookmark(isScraped: item.isSaved)
                }
            })
            .disposed(by: disposeBag)
        
        profileImageView.rx.tapGesture()
            .bind(onNext: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didClickUserProfile(ownerId: self.profileImageView.tag)
            })
            .disposed(by: disposeBag)
        
        imageCollectionView.rx.modelSelected(PictureList.self)
            .bind(onNext: { [weak self] image in
                self?.delegate?.didClickContentImage(image: image)
            })
            .disposed(by: disposeBag)
    }
    
    private func addSubViews() {
        [profileImageView, nameLabel, sportLabel, gradeLabel, timeLabel,
         imageCollectionView, titleLabel, contentLabel, hashTagLabel,
         likeButton, commentButton, bookmarkButton, dividerView].forEach {
            self.contentView.addSubview($0)
        }
    }
    
    private func layout() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(20)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(8)
        }
        
        sportLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(6)
            $0.top.equalTo(nameLabel)
        }
        
        gradeLabel.snp.makeConstraints {
            $0.leading.equalTo(sportLabel.snp.trailing).offset(4)
            $0.top.equalTo(nameLabel)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
            $0.top.equalTo(self.nameLabel.snp.bottom).offset(3)
        }
        
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(self.timeLabel.snp.bottom).offset(20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        
        imageCollectionView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(100)
            $0.top.equalTo(contentLabel.snp.bottom).offset(15)
        }
        
        hashTagLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(imageCollectionView.snp.bottom).offset(15)
        }
        
        likeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(hashTagLabel.snp.bottom).offset(15)
        }
        
        commentButton.snp.makeConstraints {
            $0.leading.equalTo(likeButton.snp.trailing).offset(24)
            $0.top.equalTo(likeButton.snp.top)
        }
        
        bookmarkButton.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(10)
            $0.bottom.equalToSuperview()
        }
    }
}

extension FitSiteDetailCell {
    private func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(100),
                                                            heightDimension: .fractionalHeight(1.0)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(4.0),
                                                                         heightDimension: .absolute(100)),
                                                       subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
