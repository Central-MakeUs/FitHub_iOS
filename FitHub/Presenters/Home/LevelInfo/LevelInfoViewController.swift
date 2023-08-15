//
//  LevelInfoViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import UIKit
import RxSwift
import RxCocoa

final class LevelInfoViewController: BaseViewController {
    private let viewModel: HomeViewModel
    
    private let levelImageView = UIImageView()
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let gradeLabel = PaddingLabel(padding: .init(top: 4, left: 4, bottom: 4, right: 4)).then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
        $0.backgroundColor = .bgSub01
        $0.font = .pretendard(.labelSmall)
        $0.text = "레벨명"
    }
    
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .pretendard(.titleLarge)
        $0.textColor = .textDefault
        $0.text = "제목"
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .bgSub01
    }
    
    private let fithubLevelGuideLabel = UILabel().then {
        $0.text = "핏허브의 운동 레벨"
        $0.textColor = .textDefault
        $0.font = .pretendard(.titleMedium)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 10
    }
    
    private let expSummaryLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "경험치 안내"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyLarge02)
    }
    
    private let expDescriptionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "경험치 안내 내용"
        $0.textColor = .textSub01
        $0.font = .pretendard(.bodyMedium01)
    }
    
    private let comboSummaryLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "콤보 안내"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodyLarge02)
    }
    
    private let comboDescriptionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "콤보 안내 내용"
        $0.textColor = .textSub01
        $0.font = .pretendard(.bodyMedium01)
    }
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.fetchLevelInfo()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setupBinding() {
        viewModel.levelInfo
            .bind(onNext: { [weak self] item in
                guard let self else { return }
                levelImageView.kf.setImage(with: URL(string: item.myLevelInfo.levelIconUrl))
                let grade = "Lv.\(item.myLevelInfo.level) \(item.myLevelInfo.levelName)"
                gradeLabel.text = grade
                gradeLabel.highlightGradeName(grade: item.myLevelInfo.levelName, highlightText: grade)
                titleLabel.text = item.myLevelInfo.levelSummary
                titleLabel.highlightGradeName(grade: item.myLevelInfo.levelName,
                                              highlightText: item.myLevelInfo.levelName)
                descriptionLabel.text = item.myLevelInfo.levelDescription
                
                expSummaryLabel.text = item.fithubLevelInfo.expSummary
                expDescriptionLabel.text = item.fithubLevelInfo.expDescription
                comboSummaryLabel.text = item.fithubLevelInfo.comboSummary
                comboDescriptionLabel.text = item.fithubLevelInfo.comboDescription

                item.fithubLevelInfo.fithubLevelList.forEach {
                    self.stackView.addArrangedSubview(LevelIconView(item: $0))
                }
                
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        title = "내 레벨"
    }
    
    override func addSubView() {
        self.view.addSubview(scrollView)
        
        [levelImageView, gradeLabel, titleLabel, descriptionLabel, dividerView,
         fithubLevelGuideLabel, stackView, expSummaryLabel, expDescriptionLabel,
         comboSummaryLabel, comboDescriptionLabel]
            .forEach {
                scrollView.addSubview($0)
            }
    }
    
    override func layout() {
        scrollView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        levelImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }
        
        gradeLabel.snp.makeConstraints {
            $0.top.equalTo(levelImageView.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(gradeLabel.snp.bottom).offset(26)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(26)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(self.view.frame.width)
            $0.height.equalTo(10)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(42)
        }
        
        fithubLevelGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(dividerView.snp.bottom).offset(42)
        }
        
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(fithubLevelGuideLabel.snp.bottom).offset(25)
            $0.height.equalTo(74)
        }
        
        expSummaryLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(stackView.snp.bottom).offset(20)
        }
        
        expDescriptionLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(expSummaryLabel.snp.bottom).offset(10)
        }
        
        comboSummaryLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(expDescriptionLabel.snp.bottom).offset(15)
        }
        
        comboDescriptionLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(comboSummaryLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
