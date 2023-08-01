//
//  SortSwitchView.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SortSwitchView: UIStackView {
    private let diseposeBag = DisposeBag()
    
    var currentOrder: OrderType = .recent {
        didSet {
            switch currentOrder {
            case .popularity:
                self.popularityButton.setTitleColor(.textDefault, for: .normal)
                self.recentButton.setTitleColor(.textSub02, for: .normal)
            case .recent:
                self.recentButton.setTitleColor(.textDefault, for: .normal)
                self.popularityButton.setTitleColor(.textSub02, for: .normal)
            }
        }
    }
    
    private let popularityButton = UIButton(type: .system).then {
        $0.setTitle("  인기순", for: .normal)
        $0.setTitleColor(.textSub02, for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium02)
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = .iconDisabled
    }
    
    private let recentButton = UIButton(type: .system).then {
        $0.setTitle("최신순  ", for: .normal)
        $0.setTitleColor(.textDefault, for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium02)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addArrangedSubview(recentButton)
        self.addArrangedSubview(separatorLine)
        self.addArrangedSubview(popularityButton)
        
        self.separatorLine.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(10)
        }
        
        setupBinding()
    }
    
    private func setupBinding() {
        self.popularityButton.rx.tap
            .bind(onNext: { self.currentOrder = .popularity})
            .disposed(by: diseposeBag)
        
        self.recentButton.rx.tap
            .bind(onNext: { self.currentOrder = .recent})
            .disposed(by: diseposeBag)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
