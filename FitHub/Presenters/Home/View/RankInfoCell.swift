//
//  RankInfoCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/03.
//

import UIKit


final class RankInfoCell: UITableViewCell {
    static let identifier = "RankInfoCell"
    
    //MARK: - Properties
    private let frameView = UIView().then {
        $0.backgroundColor = .bgSub01
        $0.layer.cornerRadius = 10
    }
    
    private let crownImageView = UIImageView().then {
        $0.image = UIImage(named: "king")
    }
    
    private let profileImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "DefaultProfile")
    }
    
    private let rankLabel = UILabel().then {
        $0.text = "1"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyMedium02)
    }
    
    private let rankStatusImage = UIImageView().then {
        $0.image = UIImage(named: "ic_score_high")
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "유저네임"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyMedium02)
    }
    
    private let sportLabel = PaddingLabel(padding: .init(top: 0, left: 4, bottom: 0, right: 4)).then {
        $0.text = "폴댄스"
        $0.layer.cornerRadius = 2
        $0.font = .pretendard(.labelSmall)
        $0.textColor = .textSub02
        $0.backgroundColor = .bgSub02
    }
    
    private let levelLabel = PaddingLabel(padding: .init(top: 0, left: 4, bottom: 0, right: 4)).then {
        $0.text = "Lv5. 은하"
        $0.layer.cornerRadius = 2
        $0.font = .pretendard(.labelSmall)
        $0.textColor = .error
        $0.backgroundColor = .bgSub02
    }
    
    private let certifyImage = UIImageView().then {
        $0.image = UIImage(named: "Certify")?.withTintColor(.iconEnabled)
    }
    
    private let certifyCount = UILabel().then {
        $0.text = "365회"
        $0.textColor = .textInfo
        $0.font = .pretendard(.bodySmall01)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        layout()
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
    }
    
    func configureCell(_ item: BestRecorderDTO) {
        crownImageView.isHidden = item.ranking != 1
        rankLabel.text = "\(item.ranking)"
        profileImageView.kf.setImage(with: URL(string: item.profileUrl))
        nameLabel.text = item.recorderNickName
        sportLabel.text = item.category
        certifyCount.text = "\(item.recordCount)회"
        levelLabel.text = "Lv.\(item.level) \(item.gradeName)"
        rankStatusImage.image = RankStatus(rawValue: item.rankingStatus)?.image?.withRenderingMode(.alwaysOriginal)
        
        self.levelLabel.highlightGradeName(grade: item.gradeName,
                                           highlightText: "Lv.\(item.level) \(item.gradeName)")
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        [rankLabel,rankStatusImage,frameView].forEach {
            self.addSubview($0)
        }
        
        [profileImageView,crownImageView,nameLabel,sportLabel,
         levelLabel,certifyImage,certifyCount].forEach {
            self.frameView.addSubview($0)
        }
    }
    
    private func layout() {
        rankLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.centerY)
            $0.leading.equalToSuperview().offset(11)
        }
        
        rankStatusImage.snp.makeConstraints {
            $0.centerX.equalTo(rankLabel)
            $0.top.equalTo(rankLabel.snp.bottom).offset(2)
        }
        
        frameView.snp.makeConstraints {
            $0.leading.equalTo(rankLabel.snp.trailing).offset(20)
            $0.top.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        sportLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-15)
            $0.leading.equalTo(nameLabel)
        }
        
        levelLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-15)
            $0.leading.equalTo(sportLabel.snp.trailing).offset(4)
        }
        
        crownImageView.snp.makeConstraints {
            $0.bottom.equalTo(profileImageView.snp.top).offset(4)
            $0.centerX.equalTo(profileImageView.snp.centerX)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(nameLabel)
            $0.width.height.equalTo(40)
            $0.leading.equalToSuperview().offset(15)
        }
        
        certifyCount.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.centerY.equalToSuperview()
        }
        
        certifyImage.snp.makeConstraints {
            $0.trailing.equalTo(self.certifyCount.snp.leading).offset(-2)
            $0.width.height.equalTo(24)
            $0.centerY.equalTo(certifyCount.snp.centerY)
        }
    }
}
