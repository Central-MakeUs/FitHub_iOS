//
//  SearchTotalHeaderView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/16.
//

import UIKit
import RxSwift

final class SearchTotalHeaderView: UICollectionReusableView {
    static let identifier = "SearchTotalHeaderView"
    static let certification = "SearchTotalHeaderViewCertification"
    static let fitSite = "SearchTotalHeaderViewFitSite"
    
    private let disposeBag = DisposeBag()
    var didTapMore: (()->Void)?
    
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.titleLarge)
        $0.textColor = .textSub01
        $0.text = "분류"
    }
    
    private let moreButton = UIButton().then {
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(.textSub02, for: .normal)
    }
    
    var title: String = "" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(moreButton)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-25)
        }
        
        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-25)
        }
        
        moreButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.didTapMore?()
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
