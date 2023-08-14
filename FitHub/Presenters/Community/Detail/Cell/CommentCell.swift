//
//  CommentCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/13.
//

import UIKit
import RxSwift

protocol CommentCellDelegate: AnyObject {
    func toggleLike(commentId: Int, completion: @escaping (LikeCommentDTO)->Void)
    func didClickMoreButton(ownerId: Int, commentId: Int)
}

final class CommentCell: UICollectionViewCell {
    static let identifier = "CommentCell"
    
    weak var delegate: CommentCellDelegate?
    private let disposeBag = DisposeBag()
    
    private let profileImageView = UIImageView(image: UIImage(named: "DefaultProfile")).then {
        $0.layer.cornerRadius = 15
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
    
    private let moreButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "ic_more_14px")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private let commentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .white
        $0.text = "댓글내용"
    }
    
    private let likeButton = UIButton().then {
        var configure = UIButton.Configuration.plain()
        configure.image = UIImage(named: "ic_heart_14px")?.withRenderingMode(.alwaysOriginal)
        configure.title = "-"
        configure.imagePlacement = .leading
        configure.imagePadding = 4
        configure.baseForegroundColor = .textSub02
        configure.attributedTitle?.font = .pretendard(.labelSmall)

        $0.configuration = configure
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        layout()
        setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: CommentDTO) {
        
        self.nameLabel.text = item.userInfo.nickname
        self.sportLabel.text = item.userInfo.mainExerciseInfo.category
        let grade = "Lv.\(item.userInfo.mainExerciseInfo.level) \(item.userInfo.mainExerciseInfo.gradeName)"
        self.gradeLabel.text = grade
        self.gradeLabel.highlightGradeName(grade: item.userInfo.mainExerciseInfo.gradeName, highlightText: grade)
        self.timeLabel.text = item.createdAt
        self.commentLabel.text = item.contents
        self.profileImageView.kf.setImage(with: URL(string: item.userInfo.profileUrl ?? ""))
        
        self.configureLikeButton(isLiked: item.isLiked)
        self.likeButton.configuration?.title = "\(item.likes)"
        self.likeButton.configuration?.attributedTitle?.font = .pretendard(.labelSmall)
        self.likeButton.tag = item.commentId
        self.moreButton.tag = item.userInfo.ownerId
    }
    
    func configureLikeButton(isLiked: Bool) {
        let image = isLiked ? UIImage(named: "ic_heart_fill_14px") : UIImage(named: "ic_heart_14px")
        let color: UIColor = isLiked ? .error : .textSub02
        
        self.likeButton.configuration?.baseBackgroundColor = color
        self.likeButton.configuration?.image = image?.withRenderingMode(.alwaysOriginal)
    }
    
    private func setUpBinding() {
        likeButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.toggleLike(commentId: self.likeButton.tag) { [weak self] item in
                    let image = item.isLiked ? UIImage(named: "ic_heart_fill_14px") : UIImage(named: "ic_heart_14px")
                    self?.likeButton.configuration?.image = image?.withRenderingMode(.alwaysOriginal)
                    self?.likeButton.configuration?.title = "\(item.newLikes)"
                    self?.likeButton.configuration?.attributedTitle?.font = .pretendard(.labelSmall)
                }
            })
            .disposed(by: disposeBag)
        
        moreButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.didClickMoreButton(ownerId: self.moreButton.tag,
                                                  commentId: self.likeButton.tag)
            })
            .disposed(by: disposeBag)
    }
    
    private func addSubViews() {
        [profileImageView, nameLabel, sportLabel, gradeLabel, timeLabel, moreButton,
        commentLabel, likeButton, separatorLine].forEach {
            self.addSubview($0)
        }
    }
    
    private func layout() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(15)
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
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.trailing.equalToSuperview()
        }
        
        commentLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
        }
        
        likeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalTo(commentLabel.snp.bottom).offset(8)
        }
        
        separatorLine.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.bottom).offset(15)
            $0.height.equalTo(1)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
