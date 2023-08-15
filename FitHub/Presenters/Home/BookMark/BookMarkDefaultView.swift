//
//  BookMarkDefaultView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import UIKit

final class BookMarkDefaultView: UIView {
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "보관된 글이 없습니다."
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyLarge02)
    }
    
    private let contentLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
        $0.text = "핏사이트에서 글을 읽고 관심글을 보관해보세요!"
    }
    
    let moveFitSteButton = UIButton().then {
        var configure = UIButton.Configuration.bordered()
        configure.contentInsets = .init(top: 10, leading: 14, bottom: 10, trailing: 14)
        configure.baseForegroundColor = .black
        configure.background.backgroundColor = .primary
        configure.background.cornerRadius = 20
        configure.title = "글 보러가기"
        configure.attributedTitle?.font = .pretendard(.bodyLarge02)
        
        $0.configuration = configure
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubViews() {
        [titleLabel, contentLabel, moveFitSteButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.centerX.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
        }
        
        moveFitSteButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(contentLabel.snp.bottom).offset(15)
        }
    }
}
