//
//  AlramCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/24.
//

import UIKit

enum AlarmType: String {
    case fitSite = "ARTICLE"
    case certification = "RECORD"
    
    var title: String {
        switch self {
        case .certification: return "운동인증"
        case .fitSite: return "핏사이트"
        }
    }
}

final class AlramCell: UITableViewCell {
    static let identifier = "AlramCell"
    
    private let typeLabel = UILabel().then {
        $0.font = .pretendard(.bodySmall02)
        $0.textColor = .primary
    }
    
    private let contentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .pretendard(.bodyLarge01)
        $0.textColor = .iconDefault
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .pretendard(.bodySmall01)
        $0.textColor = .textInfo
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
        layout()
        
        self.backgroundColor = .bgDefault
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: AlarmDTO) {
        typeLabel.text = AlarmType(rawValue: item.alarmType)?.title
        contentLabel.text = item.alarmBody
        timeLabel.text = item.createdAt
        
        if item.isConfirmed {
            typeLabel.textColor = .textInfo
            contentLabel.textColor = .iconDisabled
            timeLabel.textColor = .textDisabled
        } else {
            typeLabel.textColor = .primary
            contentLabel.textColor = .iconDefault
            timeLabel.textColor = .textInfo
        }
    }
    
    private func addSubViews() {
        [typeLabel, contentLabel, timeLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func layout() {
        typeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(typeLabel.snp.bottom).offset(10)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(contentLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}
