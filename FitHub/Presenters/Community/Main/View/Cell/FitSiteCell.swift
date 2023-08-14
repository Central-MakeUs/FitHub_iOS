//
//  FitSiteCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/08.
//

import UIKit

final class FitSiteCell: UITableViewCell {
    static let identifier = "FitSiteCell"
    
    private let profileImageView = UIImageView().then {
        $0.image = UIImage(named: "DefaultProfile")
        $0.contentMode = .scaleAspectFit
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
    
    private let titleLabel = UILabel().then {
        $0.textColor = .textDefault
        $0.text = "제목"
        $0.font = .pretendard(.titleMedium)
    }
    
    private let contentLabel = UILabel().then {
        $0.text = "내용"
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
        $0.numberOfLines = 2
    }
    
    private let hashTagLabel = UILabel().then {
        $0.text = "#해시태그"
        $0.textColor = .secondary
        $0.font = .pretendard(.labelLarge)
    }
    
    private let contentImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
        $0.contentMode = .scaleAspectFill
    }
    
    private let heartImageView = UIImageView(image: UIImage(named: "ic_heart_default"))
    
    private let heartCountLabel = UILabel().then {
        $0.text = "-"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
    }
    
    private let commentsImageView = UIImageView(image: UIImage(named: "ic_comment_14"))
    
    private let commentsCountLabel = UILabel().then {
        $0.text = "-"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: ArticleDTO) {
        self.nameLabel.text = item.userInfo.nickname
        self.sportLabel.text = item.userInfo.mainExerciseInfo.category
        let grade = "Lv.\(item.userInfo.mainExerciseInfo.level) \(item.userInfo.mainExerciseInfo.gradeName)"
        self.gradeLabel.text = grade
        self.gradeLabel.highlightGradeName(grade: item.userInfo.mainExerciseInfo.gradeName, highlightText: grade)
        self.timeLabel.text = item.createdAt
        self.titleLabel.text = item.title
        self.contentLabel.text = item.contents
        self.heartCountLabel.text = String(item.likes)
        self.commentsCountLabel.text = String(item.comments)
        
        if let tag = item.exerciseTag {
            self.hashTagLabel.text = "#"+tag
        } else {
            self.hashTagLabel.text = nil
        }
        
        self.contentImageView.kf.setImage(with: URL(string: item.pictureUrl ?? ""))
        self.profileImageView.kf.setImage(with: URL(string: item.userInfo.profileUrl ?? ""))
    }
    
    private func addSubViews() {
        [profileImageView, nameLabel, sportLabel, gradeLabel, timeLabel]
            .forEach {
                self.contentView.addSubview($0)
            }
        [titleLabel, contentLabel, hashTagLabel, contentImageView]
            .forEach {
                self.contentView.addSubview($0)
            }
        [heartImageView, heartCountLabel, commentsImageView, commentsCountLabel, separatorLine]
            .forEach {
                self.contentView.addSubview($0)
            }
    }
    
    private func layout() {
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.height.width.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(20)
        }
        
        sportLabel.snp.makeConstraints {
            $0.leading.equalTo(self.nameLabel.snp.trailing).offset(6)
            $0.top.equalToSuperview().offset(20)
        }
        
        gradeLabel.snp.makeConstraints {
            $0.leading.equalTo(self.sportLabel.snp.trailing).offset(4)
            $0.top.equalToSuperview().offset(20)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(self.nameLabel)
            $0.top.equalTo(self.nameLabel.snp.bottom).offset(3)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.timeLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(self.contentImageView.snp.leading).offset(-12)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(self.titleLabel)
        }
        
        contentImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalTo(self.timeLabel.snp.bottom).offset(20)
            $0.width.height.equalTo(70)
        }
        
        hashTagLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(contentLabel.snp.bottom).offset(12)
        }
        
        heartImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(self.hashTagLabel.snp.bottom).offset(13)
            $0.height.width.equalTo(14)
            $0.bottom.equalTo(separatorLine.snp.top).offset(-20)
        }
        
        heartCountLabel.snp.makeConstraints {
            $0.leading.equalTo(heartImageView.snp.trailing).offset(3)
            $0.centerY.equalTo(heartImageView)
        }
        
        commentsImageView.snp.makeConstraints {
            $0.leading.equalTo(self.heartCountLabel.snp.trailing).offset(18)
            $0.centerY.equalTo(heartImageView)
        }
        
        commentsCountLabel.snp.makeConstraints {
            $0.leading.equalTo(self.commentsImageView.snp.trailing).offset(3)
            $0.centerY.equalTo(heartImageView)
        }
        
        separatorLine.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}
