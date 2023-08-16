//
//  SearchBar.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import UIKit

final class CustomSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.searchTextField.layer.masksToBounds = true
        self.searchTextField.backgroundColor = .bgSub01
        self.searchTextField.layer.cornerRadius = 20
        self.searchTextField.attributedPlaceholder = .init(string: "키워드와 태그로 검색하기",
                                                           attributes: [.foregroundColor : UIColor.textInfo,
                                                                        .font : UIFont.pretendard(.bodyMedium01)])
        
        if let clearButton = self.searchTextField.value(forKeyPath: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(named: "CancelIcon"), for: .normal)
        }
        let leftView = UIView(frame: CGRectMake(0, 0, 34, 24))
        let imgView = UIImageView(image: UIImage(named: "searchIcon")?.withRenderingMode(.alwaysOriginal))
        imgView.frame = .init(x: 10, y: 0, width: 24, height: 24)
        leftView.addSubview(imgView)
        
        self.searchTextField.leftView = leftView
    }
    
    private func layout() {
        self.searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(60)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(44)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

