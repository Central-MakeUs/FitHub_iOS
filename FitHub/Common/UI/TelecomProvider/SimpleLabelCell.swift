//
//  SimpleLabelCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/29.
//

import UIKit

final class SimpleLabelCell: UITableViewCell {
    static let identifier = "SimpleLabelCell"
    
    //MARK: - Properties
    private let label = UILabel().then {
        $0.font = .pretendard(.bodyLarge01)
        $0.textColor = .textSub02
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .bgSub01
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.addSubview(label)
        
        self.label.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func configureCell(_ type: TelecomProviderType) {
        self.label.text = type.rawValue
    }
}
