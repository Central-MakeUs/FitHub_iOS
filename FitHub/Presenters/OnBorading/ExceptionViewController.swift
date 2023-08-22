//
//  ExceptionViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/23.
//

import UIKit

final class ExceptionViewController: BaseViewController {
    private let mainImageView = UIImageView(image: UIImage(named: "ExceptionImage")?.withRenderingMode(.alwaysOriginal)).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "아직 준비중이에요!"
        $0.font = .pretendard(.headLineSmall)
        $0.textColor = .textDefault
    }
    
    private let subTitleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "핏허브에서 열심히 공사중이니 조금만 기다려주시면 감사하겠습니다!"
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    init(title: String?, subTitle: String?) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        super.init(nibName: nil, bundle: nil)
        guard let bgImage = UIImage(named: "OnBoardingBG") else { return }
        view.backgroundColor = UIColor(patternImage: bgImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubView() {
        [mainImageView,titleLabel,subTitleLabel].forEach {
            view.addSubview($0)
        }
    }
    
    override func layout() {
        mainImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(46)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}
