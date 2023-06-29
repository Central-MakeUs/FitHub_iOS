//
//  TelecomProviderSelectorViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/29.
//

import UIKit
import RxSwift
import RxCocoa

final class TelecomProviderSelectorViewController: BaseViewController {
    let viewModel: RegistInfoViewModel
    
    //MARK: - Properties
    private lazy var frameViwe = UIView().then {
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
    }
    
    private let handleBarImageView = UIImageView().then {
        $0.image = UIImage(named: "HandleBar")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(.titleMedium)
        $0.textColor = .textDefault
        $0.textAlignment = .center
        $0.text = "통신사 선택"
    }
    
    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.register(SimpleLabelCell.self, forCellReuseIdentifier: SimpleLabelCell.identifier)
        $0.isScrollEnabled = false
    }
    
    //MARK: - Init
    init(viewModel: RegistInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .darkText.withAlphaComponent(0.8)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - binding
    override func setupBinding() {
        self.viewModel.telecomProviders
            .bind(to: self.tableView.rx.items(cellIdentifier: SimpleLabelCell.identifier, cellType: SimpleLabelCell.self)) { (index, value, cell) in
                cell.configureCell(value)
            }
            .disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(TelecomProviderType.self)
            .bind(onNext: { [weak self] item in
                guard let self else { return }
                self.viewModel.selectedTelecomProvider.accept(item)
                self.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Selector
    @objc private func responseToGesture() {
        self.dismiss(animated: false)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.frameViwe)
        
        self.frameViwe.addSubview(self.handleBarImageView)
        self.frameViwe.addSubview(self.titleLabel)
        self.frameViwe.addSubview(self.tableView)
    }
    
    //MARK: - Layout
    override func layout() {
        self.frameViwe.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(360)
        }
        
        self.handleBarImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.handleBarImageView.snp.bottom).offset(20)
        }
        
        self.tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.titleLabel.snp.bottom)
        }
    }
    
    override func setupAttributes() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(responseToGesture))
        swipeGesture.direction = .down

        self.frameViwe.addGestureRecognizer(swipeGesture)
    }
}
