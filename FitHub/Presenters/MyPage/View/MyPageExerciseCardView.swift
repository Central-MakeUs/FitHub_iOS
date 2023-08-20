//
//  MyPageExerciseCardView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/17.
//

import UIKit
import RxSwift

final class MyPageExerciseCardView: UIView {
    private let disposeBag = DisposeBag()
    
    let titleLabel = UILabel().then {
        $0.text = "서브 운동"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyLarge02)
    }
    
    private let categoryLabel = PaddingLabel(padding: .init(top: 2, left: 4, bottom: 2, right: 4)).then {
        $0.text = "스포츠"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub02
    }
    
    private let gradeLabel = PaddingLabel(padding: .init(top: 2, left: 4, bottom: 2, right: 4)).then {
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub02
        $0.layer.cornerRadius = 2
        $0.text = "Lv100.코딩지옥"
        $0.textColor = .textSub02
        $0.font = .pretendard(.labelSmall)
    }
    
    private let progressView = UIProgressView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
        $0.progressTintColor = .primary
        $0.backgroundColor = .bgSub02
    }
    
    private let changeMainExerciseButton = UIButton(type: .system).then {
        let title = "메인 운동 변경"
        let attributedString = NSAttributedString(string: title,
                                                  attributes: [ .font : UIFont.pretendard(.bodySmall01),
                                                                .foregroundColor : UIColor.textSub02,
                                                                .underlineStyle : 1])
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let maxExPLabel = UILabel().then {
        $0.text = "/ 1200"
        $0.textColor = .textInfo
        $0.font = .pretendard(.bodySmall02)
    }

    private let expLabel = UILabel().then {
        $0.text = "800 "
        $0.textColor = .primary
        $0.font = .pretendard(.bodySmall02)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .bgSub01
        self.layer.cornerRadius = 15
        
        self.addSubView()
        self.layout()
        
        progressView.progress = 0.8
        
        setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureInfo(_ item: MyExerciseItemDTO) {
        self.categoryLabel.text = item.category
        self.expLabel.text = "\(item.exp) "
        self.maxExPLabel.text = "/ \(item.maxExp)"
        let value = Float(item.exp) / Float(item.maxExp)
        self.progressView.progress = value
        
        let grade = "Lv.\(item.level) \(item.gradeName)"
        self.gradeLabel.text = grade
        self.gradeLabel.highlightGradeName(grade: item.gradeName, highlightText: grade)
    }
    
    private func setUpBinding() {
        changeMainExerciseButton.rx.tap
            .subscribe(onNext: { 
                NotificationCenter.default.post(name: .tapChangeMainExercise, object: nil)
            })
            .disposed(by: disposeBag)
    }

    private func addSubView() {
        [titleLabel, categoryLabel, gradeLabel, progressView, maxExPLabel, expLabel, changeMainExerciseButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(17)
        }
        
        self.categoryLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(6)
        }
        
        self.gradeLabel.snp.makeConstraints {
            $0.leading.equalTo(categoryLabel.snp.trailing).offset(3)
            $0.centerY.equalTo(categoryLabel)
        }
        
        self.progressView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.categoryLabel.snp.bottom).offset(30)
            $0.height.equalTo(10)
        }
        
        self.maxExPLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalTo(self.progressView.snp.top).offset(-5)
        }
        
        self.expLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.maxExPLabel.snp.leading)
            $0.bottom.equalTo(self.progressView.snp.top).offset(-5)
        }
        
        self.changeMainExerciseButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.top.equalToSuperview().inset(17)
        }
    }
}
