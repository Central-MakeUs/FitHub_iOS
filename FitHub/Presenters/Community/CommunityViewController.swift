//
//  CommunityViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit

final class CommunityViewController: BaseViewController {
    private let searchBar = FitHubSearchBar()
    
    private lazy var topTabbar: FitHubTopTabbar = {
        let tabbar = FitHubTopTabbar([TopTabbarItem("운동인증"),
                                      TopTabbarItem("핏사이트")])
        
        return tabbar
    }()
    
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    override func configureNavigation() {
        let noti = UIBarButtonItem(image: UIImage(named: "Alert")?.withRenderingMode(.alwaysOriginal),
                                   style: .plain, target: nil, action: nil)
        let bookmark = UIBarButtonItem(image: UIImage(named: "BookMark")?.withRenderingMode(.alwaysOriginal),
                                       style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [noti,bookmark]
        
        self.navigationItem.titleView = searchBar
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(topTabbar)
    }
    
    //MARK: - layout
    override func layout() {
        self.topTabbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(6)
            $0.height.equalTo(50)
        }
    }
}

