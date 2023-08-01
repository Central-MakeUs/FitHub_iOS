//
//  CreateActionSheet.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import UIKit

final class CreateActionSheet: UIStackView {
    let certificationButton = UIButton(type: .system).then {
        var configure = UIButton.Configuration.filled()
        configure.title = "운동 인증하기"
        configure.image = UIImage(named: "Certify")?.withRenderingMode(.alwaysOriginal)
        configure.imagePadding = 10
        configure.baseForegroundColor = .textDefault
        configure.baseBackgroundColor = .clear
        $0.configuration = configure
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = .bgSub02
    }
    
    let createFeedButton = UIButton(type: .system).then {
        var configure = UIButton.Configuration.filled()
        configure.title = "게시글 작성하기"
        configure.image = UIImage(named: "Write")?.withRenderingMode(.alwaysOriginal)
        configure.imagePadding = 10
        configure.baseBackgroundColor = .clear
        configure.baseForegroundColor = .textDefault
        $0.configuration = configure
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
        
        self.layer.cornerRadius = 10
        self.backgroundColor = .bgSub01
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - AddSubView
    private func addSubView() {
        self.addSubview(certificationButton)
        self.addSubview(separatorLine)
        self.addSubview(createFeedButton)
    }
    
    //MARK: - Layout
    private func layout() {
        self.certificationButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.equalToSuperview().offset(12)
        }
        
        self.separatorLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.top.equalTo(self.certificationButton.snp.bottom).offset(12)
        }
        
        self.createFeedButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(self.separatorLine.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
