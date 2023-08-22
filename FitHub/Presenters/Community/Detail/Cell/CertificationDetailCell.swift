//
//  CertificationDetailCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import UIKit
import RxSwift

protocol CertificationDetailCellDelegate: AnyObject {
    func toggleLike(articleId: Int, completion: @escaping (LikeCertificationDTO)->Void)
    func didClickUserProfile(ownerId: Int)
}

final class CertificationDetailCell: UICollectionViewCell {
    static let identifier = "CertificationDetailCell"
    weak var delegate: CertificationDetailCellDelegate?
    
    private let disposeBag = DisposeBag()
    
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
    
    private let contentImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub01
        $0.contentMode = .scaleAspectFill
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
    
    func configureCell(item: CertificationDetailDTO) {
        self.nameLabel.text = item.userInfo.nickname
        self.sportLabel.text = item.recordCategory.name
        let grade = "Lv.\(item.userInfo.mainExerciseInfo.level) \(item.userInfo.mainExerciseInfo.gradeName)"
        self.gradeLabel.text = grade
        self.gradeLabel.highlightGradeName(grade: item.userInfo.mainExerciseInfo.gradeName, highlightText: grade)
        self.timeLabel.text = item.createdAt
        self.contentLabel.text = item.contents
        self.hashTagLabel.text = item.hashtags.hashtags.map { "#" + $0.name }.joined(separator: " ")
        self.profileImageView.kf.setImage(with: URL(string: item.userInfo.profileUrl ?? ""))
        self.contentImageView.kf.setImage(with: URL(string: item.pictureImage ?? ""))
        
        self.configureLikeButton(isLiked: item.isLiked)
        
        likeButton.configuration?.title = "\(item.likes)"
        commentButton.configuration?.title = "\(item.comments)"
        likeButton.configuration?.attributedTitle?.font = .pretendard(.bodySmall01)
        commentButton.configuration?.attributedTitle?.font = .pretendard(.bodySmall01)
        
        profileImageView.tag = item.userInfo.ownerId
    }
    
    func configureLikeButton(isLiked: Bool) {
        let image = isLiked ? UIImage(named: "ic_heart_pressed")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "ic_heart_default")?.withTintColor(.textSub02)
        let color: UIColor = isLiked ? .error : .textSub02
        
        self.likeButton.configuration?.baseForegroundColor = color
        self.likeButton.configuration?.image = image
    }
    
    private func setUpBidning() {
        likeButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.toggleLike(articleId: self.likeButton.tag) { item in
                    self.configureLikeButton(isLiked: item.isLiked)
                    self.likeButton.configuration?.title = "\(item.newLikes)"
                    self.likeButton.configuration?.attributedTitle?.font = .pretendard(.bodySmall01)
                }
            })
            .disposed(by: disposeBag)
        
        profileImageView.rx.tapGesture()
            .bind(onNext: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didClickUserProfile(ownerId: self.profileImageView.tag)
            })
            .disposed(by: disposeBag)
    }
    
    private func addSubViews() {
        [profileImageView, nameLabel, sportLabel, gradeLabel, timeLabel,
         contentImageView, contentLabel, hashTagLabel, likeButton, commentButton, dividerView].forEach {
            self.addSubview($0)
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
        
        contentImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.timeLabel.snp.bottom).offset(20)
            $0.height.equalTo(self.contentImageView.snp.width).multipliedBy(1.33)
        }
        
        contentLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(contentImageView.snp.bottom).offset(20)
        }
        
        hashTagLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(contentLabel.snp.bottom).offset(15)
        }
        
        likeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(hashTagLabel.snp.bottom).offset(15)
        }
        
        commentButton.snp.makeConstraints {
            $0.leading.equalTo(likeButton.snp.trailing).offset(24)
            $0.top.equalTo(likeButton.snp.top)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(10)
            $0.bottom.equalToSuperview()
        }
    }
}
