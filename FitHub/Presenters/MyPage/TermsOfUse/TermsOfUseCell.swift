//
//  TermsOfUseCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import UIKit

final class TermsOfUseCell: UITableViewCell {
    static let identifier = "TermsOfUseCell"

    private let termOfUseItemView = MyPageTabItemView(title: "약관")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .bgDefault
        
        self.addSubview(termOfUseItemView)
        
        termOfUseItemView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.verticalEdges.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(item: TermsDTO) {
        termOfUseItemView.configureTitle(title: item.title)
    }
}
