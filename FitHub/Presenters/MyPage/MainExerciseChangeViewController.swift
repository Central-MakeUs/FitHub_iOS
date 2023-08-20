//
//  MainExerciseChangeViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/18.
//

import UIKit
import RxCocoa
import RxSwift

final class MainExerciseChangeViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: MyPageViewModel
    
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
        $0.register(SportCell.self, forCellWithReuseIdentifier: SportCell.identifier)
        $0.backgroundColor = .clear
    }
    
    private let changeButton = StandardButton(type: .system).then {
        $0.setTitle("변경하기", for: .normal)
    }
    
    //MARK: - Init
    init(_ viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.gestureRecognizers = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchCategory()
        viewModel.getCurrentMainExercise()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        viewModel.categories
            .bind(to: sportsCollectionView.rx.items(cellIdentifier: SportCell.identifier, cellType: SportCell.self)) { [weak self] index, item, cell in
                guard let self else { return }
                cell.configureCell(item: item, selectedId: self.viewModel.newCategoryId.value)
            }
            .disposed(by: disposeBag)
        
        viewModel.newCategoryId
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] _ in self?.sportsCollectionView.reloadData() })
            .disposed(by: disposeBag)
        
        sportsCollectionView.rx.modelSelected(CategoryDTO.self)
            .map { $0.id }
            .bind(to: viewModel.newCategoryId)
            .disposed(by: disposeBag)
        
        viewModel.changeButtonEnable
            .bind(to: changeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        changeButton.rx.tap.asObservable()
            .withUnretained(self)
            .flatMap { (self,_) in
                self.viewModel.changeMainExercise().asObservable()
                    .catch { _ in
                        return Observable.just(false)
                    }
            }
            .subscribe(onNext: { [weak self] isSuccess in
                if isSuccess {
                    self?.changeResultPush(content: "메인 운동 변경이 성공적으로 완료되었습니다.")
                } else {
                    self?.changeResultPush(content: "메인 운동 변경에 실패하였습니다.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func changeResultPush(content: String) {
        let alert = StandardAlertController(title: "알 림", message: content)
        let ok = StandardAlertAction(title: "확인", style: .basic) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(ok)
        
        self.present(alert, animated: false)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(subTitleLabel)
        self.view.addSubview(sportsCollectionView)
        self.view.addSubview(changeButton)
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
            $0.bottom.equalTo(self.changeButton.snp.top).offset(-20)
        }
        
        self.changeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(52)
        }
    }
}

extension MainExerciseChangeViewController {
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
