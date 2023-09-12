//
//  OtherFitSiteCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/20.
//

import UIKit

final class OtherFitSiteCell: UITableViewCell {
    static let identifier = "OtherFitSiteCell"
    
    weak var delegate: MyFitSiteCellDelegate?
    
    private let titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.textColor = .textDefault
        $0.text = "제목"
        $0.font = .pretendard(.titleMedium)
    }
    
    private let contentLabel = UILabel().then {
        $0.textAlignment = .left
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        addSubViews()
        layout()
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: ArticleDTO) {
        self.titleLabel.text = item.title
        self.contentLabel.text = item.contents
        self.heartCountLabel.text = String(item.likes)
        self.commentsCountLabel.text = String(item.comments)
        
        if let tag = item.exerciseTag {
            self.hashTagLabel.text = "#"+tag
        } else {
            self.hashTagLabel.text = nil
        }
        
        responseContentImageViewLayout(image: item.pictureUrl)
        
        self.contentImageView.kf.setImage(with: URL(string: item.pictureUrl ?? ""))
    }
    
    private func responseContentImageViewLayout(image: String?) {
        let height = image == nil ? 0 : 70
        contentImageView.snp.updateConstraints() {
            $0.width.height.equalTo(height)
        }
    }
        
    private func addSubViews() {
        [titleLabel, contentLabel, hashTagLabel, contentImageView, separatorLine]
            .forEach {
                self.contentView.addSubview($0)
            }
    }
    
    private func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(self.contentImageView.snp.leading).offset(-12)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        contentImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel)
            $0.width.height.equalTo(70)
        }
        
        hashTagLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(contentLabel.snp.bottom).offset(12)
        }
        
        separatorLine.snp.makeConstraints {
            $0.top.equalTo(hashTagLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}

