//
//  HomeViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "은하 댕우님,\n오늘도 힘내서 운동해봐요!"
        $0.font = .pretendard(.titleLarge)
        $0.textColor = .textDefault
    }
    
    private let certificationButton = UIButton(type: .system).then {
        $0.setTitleColor(.textSub01, for: .normal)
        $0.setTitle("운동인증하러가기", for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
    }
    
    private let levelImageView = UIImageView().then {
        $0.image = UIImage(named: "DefaultProfile")
        $0.contentMode = .scaleAspectFit
    }
    
    private let certifyCardView = CertifyCardView()
    
    private let nearbyGymGuideLabel = UILabel().then {
        $0.text = "내 근처 운동시설 둘러보기"
        $0.textColor = .textDefault
        $0.font = .pretendard(.titleMedium)
    }
    
    private let certificationRankerLabel = UILabel().then {
        $0.text = "최고의 운동 인증러"
        $0.textColor = .textDefault
        $0.font = .pretendard(.titleMedium)
    }
    
    private let updateTimeLabel = UILabel().then {
        $0.font = .pretendard(.bodySmall01)
        $0.textColor = .iconSub
        $0.text = "2023.06.30 17:00 기준"
    }
    
    private let rankerTableView = UITableView().then {
        $0.register(RankInfoCell.self, forCellReuseIdentifier: RankInfoCell.identifier)
        $0.backgroundColor = .blue
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(SportCell.self, forCellWithReuseIdentifier: SportCell.identifier)
    }
    
    override func setupAttributes() {
        self.addNotificationCenter()
    }
    
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "logo_basic")))
        
        let noti = UIBarButtonItem(image: UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal),
                                   style: .plain, target: nil, action: nil)
        let bookmark = UIBarButtonItem(image: UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal),
                                       style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [noti,bookmark]
        
    }
    
    override func setupBinding() {
        Observable.of(["테니스","수영","스케이트","클라이밍","테니스","수영","스케이트","클라이밍"])
            .bind(to: self.collectionView.rx.items(cellIdentifier: SportCell.identifier, cellType: SportCell.self)) { index, item, cell in
                cell.configureCell(item: CategoryDTO.init(createdAt: "", updatedAt: "", imageUrl: "", name: item, id: 0), selectedItem: nil)
                
            }
            .disposed(by: disposeBag)
        
        Observable.of(["더미1","더미2","더미3","더미4","더미5"])
            .bind(to: self.rankerTableView.rx.items(cellIdentifier: RankInfoCell.identifier, cellType: RankInfoCell.self)) { index, item, cell in
                print("왜..")
            }
            .disposed(by: disposeBag)
        
    }
    
    override func addSubView() {
        self.view.addSubview(scrollView)
        
        [titleLabel, certificationButton, levelImageView,
         certifyCardView, nearbyGymGuideLabel, collectionView,
         certificationRankerLabel, updateTimeLabel, rankerTableView].forEach {
            self.scrollView.addSubview($0)
        }
    }
    
    override func layout() {
        self.scrollView.snp.makeConstraints {
            $0.trailing.top.bottom.leading.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
        }
        
        self.certificationButton.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.levelImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.width.height.equalTo(80)
        }
        
        self.certifyCardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.certificationButton.snp.bottom).offset(33)
            $0.height.equalTo(167)
        }
        
        self.nearbyGymGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(self.certifyCardView.snp.bottom).offset(60)
        }
        
        self.collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.nearbyGymGuideLabel.snp.bottom).offset(20)
            $0.height.equalTo(100)
        }
        
        self.certificationRankerLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(self.view.frame.width-40)
            $0.top.equalTo(self.collectionView.snp.bottom).offset(50)
        }
        
        self.updateTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.certificationRankerLabel.snp.bottom).offset(6)
        }
        
        self.rankerTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.updateTimeLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview()
        }
    }
}

extension HomeViewController {
    private func addNotificationCenter() {
        NotificationCenter.default.rx.notification(.presentAlert)
            .subscribe(onNext: { [weak self] notification in
                let authRepository = OAuthLoginRepository(AuthService())
                let authVC = UINavigationController(rootViewController: OAuthLoginViewController(
                    OAuthLoginViewModel(OAuthLoginUseCase(authRepository))))
                authVC.modalPresentationStyle = .fullScreen
                
                self?.present(authVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumInteritemSpacing = 5
            $0.itemSize = .init(width: 74, height: 100)
            $0.sectionInsetReference = .fromContentInset
            $0.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        return layout
    }
}

