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
        $0.backgroundColor = .clear
    }
    
    private let registButton = StandardButton(type: .system).then {
        $0.setTitle("핏허브 입장하기", for: .normal)
    }
    
    //MARK: - Init
    init(_ viewModel: SportsSelectingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.gestureRecognizers = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        let input = SportsSelectingViewModel.Input(didSelectItemEvent: self.sportsCollectionView.rx.modelSelected(CategoryDTO.self).asObservable(),
                                                   didDeSelectItemEvent: self.sportsCollectionView.rx.modelDeselected(CategoryDTO.self).asObservable(),
                                                   registTap: self.registButton.rx.tap.asSignal())
        
        let output = self.viewModel.transform(input: input)
        
        output.sports
            .bind(to: self.sportsCollectionView.rx.items(cellIdentifier: SportsCell.identifier,
                                                         cellType: SportsCell.self)) {index,category,cell in
                cell.configureCell(item: category)
            }
            .disposed(by: disposeBag)
        
        self.sportsCollectionView.rx.itemSelected
            .bind(onNext: { [weak self] indexPath in
                self?.sportsCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            })
            .disposed(by: disposeBag)
        
        self.sportsCollectionView.rx.itemDeselected
            .bind(onNext: { [weak self] indexPath in
                self?.sportsCollectionView.deselectItem(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.registButtonEnable
            .bind(to: self.registButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.registPublisher
            .bind(onNext: { [weak self] nickName in
                guard let self else { return }
                if let nickName {
                    let tabBar = self.setTapbar()
                    self.changeRootViewController(tabBar)
                } else {
                    self.notiAlert("회원가입 실패. 다시 시도해주세요.")
                }
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
            $0.leading.trailing.equalToSuperview()
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
