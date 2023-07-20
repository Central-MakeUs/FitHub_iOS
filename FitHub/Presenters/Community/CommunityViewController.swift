//
//  CommunityViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit

final class CommunityViewController: BaseViewController {
    private let searchBar = FitHubSearchBar()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(navigationItem.titleView?.frame.height)
        print(searchBar.frame.height)
        print(searchBar.searchTextField.frame.height)
    }
}

