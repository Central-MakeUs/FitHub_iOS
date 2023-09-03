//
//  FacilityCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/30.
//

import UIKit

final class FacilityCell: UITableViewCell {
    static let identifier = "FacilityCell"
    
    let infoView = FacilityCard()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .bgDefault
        self.selectionStyle = .none
        
        self.addSubview(infoView)
        
        infoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
