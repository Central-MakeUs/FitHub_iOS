//
//  TermsOfUseViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

final class TermsOfUseViewController: BaseViewController {
    private let viewModel: TermOfUseViewModel
    
    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .bgDefault
        $0.register(TermsOfUseCell.self, forCellReuseIdentifier: TermsOfUseCell.identifier)
    }
    
    init(viewModel: TermOfUseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.title = "약관 및 정책"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.gestureRecognizers = nil
    }
    
    override func setupBinding() {
        let input = TermOfUseViewModel.Input()
        
        let output = viewModel.transform(input: input)
        
        output.termList
            .bind(to: tableView.rx.items(cellIdentifier: TermsOfUseCell.identifier, cellType: TermsOfUseCell.self)) { index, item, cell in
                cell.configureCell(item: item)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(TermsDTO.self)
            .bind(onNext: { [weak self] item in
                self?.openTermOfUseContentWithSafari(item: item)
            })
            .disposed(by: disposeBag)
    }
    
    private func openTermOfUseContentWithSafari(item: TermsDTO) {
        guard let termURL = URL(string: item.link)   else { return }

        let safariViewController = SFSafariViewController(url: termURL)
        safariViewController.modalPresentationStyle = .automatic
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    override func addSubView() {
        view.addSubview(tableView)
    }
    
    override func layout() {
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
