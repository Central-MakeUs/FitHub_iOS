//
//  AlertViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/23.
//

import UIKit
import RxSwift
import RxCocoa

final class AlertViewController: BaseViewController {
    private let viewModel: AlertViewModel
    
    private let backgroundView = AlertDefaultView()
    
    private lazy var alertTableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.register(AlramCell.self, forCellReuseIdentifier: AlramCell.identifier)
        $0.backgroundView = backgroundView
        $0.backgroundColor = .bgDefault
        $0.separatorInset = .zero
    }
    
    private let settingItem = UIBarButtonItem(image: UIImage(named: "ic_setting")?.withRenderingMode(.alwaysOriginal),
                                              style: .plain,
                                              target: nil,
                                              action: nil)
    
    init(viewModel: AlertViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchAlarmList()
        view.gestureRecognizers = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func configureNavigation() {
        super.configureNavigation()
        self.title = "알림"
        
        navigationItem.rightBarButtonItem = settingItem
        
        settingItem.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.showNotiSetting()
            })
            .disposed(by: disposeBag)
    }
    
    override func setupBinding() {
        let didScroll = alertTableView.rx.didScroll
            .map { [weak self] Void -> (offsetY: CGFloat, contentHeight: CGFloat, frameHeight: CGFloat) in
                guard let self else { return (0,0,0) }
                return (self.alertTableView.contentOffset.y,
                        self.alertTableView.contentSize.height,
                        self.alertTableView.frame.height)
            }
        
        let input = AlertViewModel.Input(didScroll: didScroll)
        
        let _ = viewModel.transform(input: input)
        
        viewModel.alarmDataList
            .bind(to: alertTableView.rx.items(cellIdentifier: AlramCell.identifier, cellType: AlramCell.self)) { index, item, cell in
                cell.configureCell(item: item)
            }
            .disposed(by: disposeBag)
        
        viewModel.alarmDataList
            .map { !$0.isEmpty }
            .bind(to: backgroundView.rx.isHidden)
            .disposed(by: disposeBag)
        
        alertTableView.rx.modelSelected(AlarmDTO.self)
            .asDriver()
            .drive(onNext: { [weak self] item in
                guard let self else { return }
                let type = AlarmType(rawValue: item.alarmType)
                viewModel.confirmAlarmm(alarmId: item.alarmId)
                if type == .fitSite {
                    self.showFitSiteDetail(targetId: item.targetId)
                } else if type == .certification {
                    self.showCertificationDetail(targetId: item.targetId)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 화면 이동
    private func showCertificationDetail(targetId: Int) {
        let usecase = CertifiactionDetailUseCase(certificationRepository: CertificationRepository(service: CertificationService()),
                                                 commentRepository: CommentRepository(service: CommentService()),
                                                 communityRepostiroy: CommunityRepository(UserService(),
                                                                                          certificationService: CertificationService(),
                                                                                          articleService: ArticleService()))
        
        let certificationDetailVC = CertificationDetailViewController(viewModel: CertificationDetailViewModel(usecase: usecase,
                                                                                                        recordId: targetId))
        
        self.navigationController?.pushViewController(certificationDetailVC, animated: true)
    }
    
    private func showFitSiteDetail(targetId: Int) {
        let usecase = FitSiteDetailUseCase(commentRepository: CommentRepository(service: CommentService()),
                                           fitSiteRepository: FitSiteRepository(service: ArticleService()),
                                           communityRepository: CommunityRepository(UserService(),
                                                                                    certificationService: CertificationService(),
                                                                                    articleService: ArticleService()))
        let fitSiteDetailVC = FitSiteDetailViewController(viewModel: FitSiteDetailViewModel(usecase: usecase,
                                                                                            articleId: targetId))
        
        self.navigationController?.pushViewController(fitSiteDetailVC, animated: true)
    }
    
    private func showNotiSetting() {
        let usecase = NotiSettingUseCase(homeRepo: HomeRepository(homeService: HomeService(),
                                                                  authService: UserService(),
                                                                  certificationService: CertificationService()))
        let notiSettingVC = NotiSettingViewController(viewModel: NotiSettingViewModel(usecase: usecase))
        self.navigationController?.pushViewController(notiSettingVC, animated: true)
    }
    
    override func addSubView() {
        view.addSubview(alertTableView)
    }
    
    override func layout() {
        alertTableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
