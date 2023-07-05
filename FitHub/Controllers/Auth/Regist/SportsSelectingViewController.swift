//
//  SportsSelectingViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import UIKit
import RxCocoa
import RxSwift

final class SportsSelectingViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: SportsSelectingViewModel
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "평소 관심있거나, 하고있는\n운동 1개 이상 선택해주세요."
        $0.textColor = .textDefault
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "선택하신 운동에 따라 맞춤 정보가 제공돼요!"
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodyMedium01)
    }
    
    private lazy var sportsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(SportsCell.self, forCellWithReuseIdentifier: SportsCell.identifier)
        $0.allowsMultipleSelection = true
        $0.backgroundColor = .white
    }
    
    private let registButton = StandardButton(type: .system).then {
        $0.setTitle("회원가입 하기", for: .normal)
    }
    
    //MARK: - Init
    init(_ viewModel: SportsSelectingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        self.viewModel.sports
            .bind(to: self.sportsCollectionView.rx.items(cellIdentifier: SportsCell.identifier, cellType: SportsCell.self)) {index,title,cell in
                cell.configureCell(item: title)
            }
            .disposed(by: disposeBag)
        
        let selectItem = Observable.zip(self.sportsCollectionView.rx.itemSelected.asObservable(), self.sportsCollectionView.rx.modelSelected(String.self).asObservable()
        )
        
        let deSelectItem = Observable.zip(self.sportsCollectionView.rx.itemDeselected.asObservable(), self.sportsCollectionView.rx.modelDeselected(String.self).asObservable()
        )
        
        let input = SportsSelectingViewModel.Input(didSelectItemEvent: selectItem,
                                                   didDeSelectItemEvent: deSelectItem,
                                                   registTap: self.registButton.rx.tap.asSignal())
        
        let output = self.viewModel.transform(input: input)
        
        output.registTap
            .emit(onNext: {
                self.notiAlert("이 부분은 API 내려오는거 보고 모델링한 뒤 마무리 할게요!")
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(subTitleLabel)
        self.view.addSubview(sportsCollectionView)
        self.view.addSubview(registButton)
    }
    
    //MARK: - layout
    override func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
        }
        
        self.subTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.sportsCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(50)
            $0.bottom.equalTo(self.registButton.snp.top).offset(-20)
        }
        
        self.registButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
    }
}

extension SportsSelectingViewController {
    func createLayout() -> UICollectionViewLayout {
        
        return UICollectionViewFlowLayout().then {
            let itemWidth = SportsCell.itemWidth
            $0.scrollDirection = .vertical
            $0.minimumInteritemSpacing = 8
            $0.minimumLineSpacing = 25
            $0.itemSize = .init(width: itemWidth, height: itemWidth + 30)
        }
    }
}
