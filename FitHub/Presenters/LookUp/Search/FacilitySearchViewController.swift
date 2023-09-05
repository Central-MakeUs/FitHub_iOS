//
//  FacilitySearchViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/09/02.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

final class FacilitySearchViewController: BaseViewController {
    private let viewModel: LookUpViewModel
    
    private let locationManager = CLLocationManager()
    
    private let backButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "BackButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private let searchBar = FitHubSearchBar().then {
        $0.searchTextField.placeholder = "지역,시설명으로 검색하기"
    }
    
    private let recommendView = RecommendView()
    
    init(viewModel: LookUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.gestureRecognizers = nil
        searchBar.searchTextField.becomeFirstResponder()
        viewModel.fetchRecommendKeyword()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func setupBinding() {
        backButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
        viewModel.recommentKeywords
            .bind(to: recommendView.keywordCollectionView.rx.items(cellIdentifier: CategoryCell.identifier, cellType: CategoryCell.self)) { index, item, cell in
                cell.isUseSelected = false
                cell.configureLabel(item)
            }
            .disposed(by: disposeBag)
        
        recommendView.keywordCollectionView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.searchQuery.accept(text)
            })
            .disposed(by: disposeBag)
        
        searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchBar.searchTextField.rx.text.orEmpty)
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)
    }

    override func addSubView() {
        [backButton, searchBar, recommendView].forEach {
            view.addSubview($0)
        }
    }
    
    override func layout() {
        backButton.snp.makeConstraints {
            $0.centerY.equalTo(searchBar)
            $0.leading.equalToSuperview().offset(20)
        }
        
        searchBar.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalTo(backButton.snp.trailing).offset(15)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.height.equalTo(44)
        }
        
        recommendView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
